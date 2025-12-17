#import "../template/lib.typ": *
#import "../template/diagram-helpers.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/chronos:0.2.1"


#show: rust-course.with(
  config-info(
    title: [Lecture 7: Asynchronous programming],
    subtitle: [Presentations students, introduction to async],
    author: [Willem Vanhulle],
    date: [Tuesday December 9, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)


#title-slide()

= Student presentations

== Time-series transformers (Wietse)

== Resource pool (Thomas)

= Asynchronous programming

== Introduction

#slide[

  Multiple tasks execute concurrently by running until they would block on I/O, then yielding to another ready task.

  #fletcher-diagram(
    spacing: (3.5em, 1em),
    node((0, 0), [Task A]),
    node((0, 1), [Task B]),
    edge((1, 0), (3, 0), "-", stroke: green + 2pt, label: [run]),
    pause,
    edge((3, 0), (5, 0), "--", stroke: red, label: [I/O wait]),
    pause,
    edge((3, 1), (5, 1), "-", stroke: green + 2pt, label: [run]),
    pause,
    edge((5, 0), (7, 0), "-", stroke: green + 2pt, label: [resume]),
  )

  #pause

  Per-task overhead is minimal because operating systems provide primitives (epoll, kqueue, IOCP) that monitor many I/O operations with a single system call.

  #fletcher-diagram(
    spacing: (2em, 1em),
    node((0, 0), [Runtime]),
    node((3, 0), [epoll/kqueue], shape: shapes.rect),
    node((6, -1), [Socket 1], shape: shapes.circle),
    node((6, 0), [Socket 2], shape: shapes.circle),
    node((6, 1), [File], shape: shapes.circle),
    edge((0, 0), (3, 0), "->", label: [single syscall]),
    edge((3, 0), (6, -1), "->"),
    edge((3, 0), (6, 0), "->"),
    edge((3, 0), (6, 1), "->"),
  )
]


== Comparison with Python

#slide[

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    [
      *Python asyncio*

      #fletcher-diagram(
        spacing: (1.5em, 1em),
        node((0, 0), [Future], shape: shapes.rect),
        node((2, -0.5), [Callback 1], shape: shapes.circle),
        node((2, 0.5), [Callback 2], shape: shapes.circle),
        edge((0, 0), (2, -0.5), "->", label: [on complete], bend: 20deg),
        edge((0, 0), (2, 0.5), "->", label: [on complete], bend: -20deg),
      )

      - Callback-based model
      - Register callbacks
      - Built-in event loop
      - Interpreter overhead
    ],
    [
      *Rust async/await*

      #fletcher-diagram(
        spacing: (1.5em, 1em),
        node((0, 0), [Runtime], shape: shapes.rect),
        node((2, 0), [Future], shape: shapes.rect),
        edge((0, 0), (2, 0), "->", label: [poll()], bend: -20deg),
        edge((2, 0), (0, 0), "->", label: [Pending/Ready], bend: -30deg),
      )

      - Poll-based model
      - Runtime polls futures
      - External runtimes (tokio, async-std)
      - Zero-cost state machines
    ],
  )
]


== Comparison with C++

#slide[

  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    [
      *C++20 Coroutines*

      #fletcher-diagram(
        spacing: (1.5em, 1em),
        node((0, 0), [`co_await`], shape: shapes.rect),
        node((2, -0.5), [Promise], shape: shapes.rect, fill: red.lighten(80%)),
        node((2, 0.5), [Awaitable], shape: shapes.rect, fill: red.lighten(80%)),
        edge((0, 0), (2, -0.5), "->", label: [manual], bend: 20deg),
        edge((0, 0), (2, 0.5), "->", label: [manual], bend: -20deg),
      )

      - Manual promise types
      - Manual awaitable objects
      - No standard runtime
      - *Heap allocation* by default
    ],
    [
      *Rust async/await*

      #fletcher-diagram(
        spacing: (2.5em, 1em),
        node(
          (0, 0),
          [`async fn`],
          shape: shapes.rect,
          fill: green.lighten(80%),
        ),
        node(
          (2, 0),
          [State machine],
          shape: shapes.rect,
          fill: green.lighten(80%),
        ),
        edge((0, 0), (2, 0), "->", label: [automatic]),
      )

      - Compiler generates state machines
      - Built-in syntax
      - Mature ecosystem (tokio)
      - *Stack-allocated* by default
    ],
  )
]

= Asynchronous Rust

== Await syntax

At a high level, async Rust code looks very much like “normal” sequential code:

```rs
use futures::executor::block_on;

async fn count_to(count: i32) {
    for i in 0..count {
        println!("Count is: {i}!");
    }
}

async fn async_main(count: i32) {
    count_to(count).await;
}

fn main() {
    block_on(async_main(10));
}
```


== Futures

#link("https://doc.rust-lang.org/std/future/trait.Future.html")[Future] is a trait, implemented by objects that represent an operation that may not be complete yet. A future can be polled, and poll returns a #link("https://doc.rust-lang.org/std/task/enum.Poll.html")[`Poll`].

```rs
use std::pin::Pin; use std::task::Context;

pub trait Future {
    type Output;
    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}

pub enum Poll<T> {
    Ready(T),
    Pending,
}
```

#qa[What is the role of `Context`?][
  Context allows a Future to schedule itself to be polled again when an event such as a timeout occurs.
]

== JoinHandle

One common type implementing `Future` is a Tokio `JoinHandle`:

```rs
use tokio::task;

let join = task::spawn(async {
    panic!("something bad happened!")
});

// The returned result indicates that the task failed.
assert!(join.await.is_err());
```

= Rust's async implementation


== State machine

Rust transforms async functions into state machines that implement `Future`.

#pause

Key characteristics:

- Calling an async function constructs and returns a future
- Does not execute immediately (lazy)
- Tracks progress through suspension points

#pause

The state machines are allocated on the stack by default. When the state machine transitions to the next state, the async runtime does not move it.


== Transformation

Consider this async function:

```rs
async fn two_d10(modifier: u32) -> u32 {
    let first_roll = roll_d10().await;
    let second_roll = roll_d10().await;
    first_roll + second_roll + modifier
}
```

#pause

The compiler generates an enum that:

- Tracks each suspension point (each `.await`)
- Stores all live variables needed at that state
- Implements the `Future` trait


== State machine structure

The generated enum looks conceptually like this:

```rs
enum TwoDiceFuture {
    Start { modifier: u32 },
    FirstRoll { modifier: u32, first_roll: impl Future<Output = u32> },
    SecondRoll { modifier: u32, first_result: u32, second_roll: impl Future<Output = u32> },
    Done,
}
```

#pause

Each state stores:
- The variables still needed
- The future being awaited (if any)


== Recursion

Deeply nested async functions create large compiler-generated Future types.

Each function's Future contains its callees' Futures.

#pause

Recursive async functions require boxing to avoid infinite type sizes:

```rs
async fn count_to(n: u32) {
    if n > 0 {
        Box::pin(count_to(n - 1)).await;
        println!("{n}");
    }
}

Box::pin(count_to(n - 1)).await;
```

#pause

This adds heap allocation overhead but makes recursion possible.

= Ecosystem

== Runtimes

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,

  [
    A runtime provides support for:

    - performing operations asynchronously (a *reactor*)
    - and is responsible for executing futures (an *executor*).

    #pause

    Rust does not have a "built-in" runtime, but several options are available:

    - `futures` offers a bare bones executor #link("https://docs.rs/futures/latest/futures/executor/struct.ThreadPool.html")[`ThreadPool`]
    - `tokio` offers a `Runtime` with reactor included (supplies "time" etc.)
  ],

  diagram(
    spacing: (15mm, 30mm),
    node-stroke: 1pt,
    {
      // Runtime container
      node(
        (0, 0),
        [*Runtime*],
        stroke: 2pt,
        shape: shapes.rect,
        name: <runtime>,
      )

      node(enclose: (<executor>, <reactor>), fill: red.lighten(50%), inset: 1em)

      // Executor
      node(
        (0, 1),
        [*Executor*],
        fill: blue.lighten(80%),
        stroke: blue + 1pt,
        name: <executor>,
      )

      // Reactor
      node(
        (0, 2),
        [*Reactor*],
        fill: green.lighten(80%),
        stroke: green + 1pt,
        name: <reactor>,
      )

      // Futures
      node((1, 0.5), [Future 1], stroke: 1pt, shape: shapes.rect, name: <f1>)
      node((1, 1.5), [Future 2], stroke: 1pt, shape: shapes.rect, name: <f2>)

      // I/O Events
      node(
        (1, 2.5),
        [I/O Events],
        stroke: 1pt,
        shape: shapes.hexagon,
        name: <io>,
      )

      // Edges
      edge(<executor>, <f1>, "->", label: text(size: 0.6em)[poll()])
      edge(<executor>, <f2>, "->", label: text(size: 0.6em)[poll()])
      edge(<io>, <reactor>, "->", label: text(size: 0.6em)[notify])
      edge(<reactor>, <executor>, "<->", label: text(size: 0.6em)[wake])
    },
  ),
)

== Tokio

```rs
use tokio::time;
async fn count_to(count: i32) {
    for i in 0..count {
        println!("Count in task: {i}!");
        time::sleep(time::Duration::from_millis(5)).await;
    }
}
#[tokio::main]
async fn main() {
    tokio::spawn(count_to(10));
    for i in 0..5 {
        println!("Main task: {i}");
        time::sleep(time::Duration::from_millis(5)).await;
    }
}
```

Async tasks are also aborted if not awaited in main.

= Common async datatypes and functions

== Tasks

A task is a top-level future that may be sent to different worker threads (if necessary).


```rs
#[tokio::main]
async fn main() -> io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:0").await?;

    loop {
        let (mut socket, addr) = listener.accept().await?;

        tokio::spawn(async move {
            // Handle connection
        });
    }
}
```

#pause

#warning[
  Although we use `tokio` in this section, the same functionality is available in most async runtimes.
]

#pagebreak()

Inside `tokio::spawn`:

```rs
socket.write_all(b"Who are you?\n").await?;

let mut buf = vec![0; 1024];
let name_size = socket.read(&mut buf).await?;
let name = std::str::from_utf8(&buf[..name_size])?.trim();

socket.write_all(format!("Thanks, {name}!\n").as_bytes()).await?;
```
== Exercise

#info[
  An async block like `async move {}` is like a scope block that may contain awaits.
]

Refactor `session7/examples/tasks.rs`:

- Create async helper function from async block
- Improve error handling


== Channels

```rs
async fn ping_handler(mut input: mpsc::Receiver<()>) {
    let mut count: usize = 0;
    while let Some(_) = input.recv().await {
        count += 1;
        println!("Received {count} pings so far.");
    }
}
```

#pause

```rs
async fn main() {
    let (sender, receiver) = mpsc::channel(32);
    let handler_task = tokio::spawn(ping_handler(receiver));
    for i in 0..10 {
        sender.send(()).await.expect("Failed to send");
    }
    drop(sender);
    handler_task.await.expect("Handler failed");
}
```

== Joining

We might need to do the same `async` function multiple times:

```rs
async fn size_of_page(url: &str) -> Result<usize> {
    let resp = reqwest::get(url).await?;
    Ok(resp.text().await?.len())
}
```


#qa[How can we await a list of futures conccurently?][We use the `join_all` function.]

#pause

```rs
async fn main() {
    let urls = ["https://google.com", "https://httpbin.org/ip", /*...*/];
    let futures = urls.into_iter().map(size_of_page);
    let results = future::join_all(futures).await;
    println!("{results:?}");
}
```

#pagebreak

#text(size: 0.8em)[
  #chronos.diagram({
    import chronos: *

    _par("Main")
    _par("join_all")
    _par("Future 1")
    _par("Future 2")
    _par("Future 3")

    _gap()
    _seq("Main", "join_all", comment: "futures collection")
    _gap()

    _seq("join_all", "Future 1", comment: "poll()", enable-dst: true)
    _seq("join_all", "Future 2", comment: "poll()", enable-dst: true)
    _seq("join_all", "Future 3", comment: "poll()", enable-dst: true)

    _gap()

    _seq("Future 2", "join_all", comment: "Ready(result2)", dashed: true)
    _note("right", "Future 2 completes first")

    _gap()

    _seq("Future 3", "join_all", comment: "Ready(result3)", dashed: true)
    _note("left", "Future 3 completes second")

    _gap()

    _seq("Future 1", "join_all", comment: "Ready(result1)", dashed: true)
    _note("right", "Future 1 completes last")

    _gap()

    _seq(
      "join_all",
      "Main",
      comment: "[result1, result2, result3]",
      dashed: true,
    )
    _note("left", "All results collected")
  })
]

== Select

Waits until any of a set of futures is ready. Similar to `Promise.race` or Python's `asyncio.wait()`.

```rs
#[tokio::main]
async fn main() {
    let (tx, mut rx) = mpsc::channel(32);

    tokio::spawn(async move {
        tokio::select! {
            Some(msg) = rx.recv() => println!("got: {msg}"),
            _ = sleep(Duration::from_millis(50)) => println!("timeout"),
        };
    });

    sleep(Duration::from_millis(10)).await;
    tx.send(String::from("Hello!")).await?;
    // ...
}
```

#pagebreak()

#text(size: 0.6em)[
  #chronos.diagram({
    import chronos: *

    _par("Main")
    _par("Task")
    _par("select!")
    _par("rx.recv()")
    _par("sleep(50ms)")

    _seq("Main", "Task", comment: "spawn", enable-dst: true)
    _seq("Task", "select!", comment: "enter select!", enable-dst: true)

    _gap()

    _seq("select!", "rx.recv()", comment: "poll()", enable-dst: true)
    _seq("select!", "sleep(50ms)", comment: "poll()", enable-dst: true)
    _seq("rx.recv()", "select!", comment: "Pending", dashed: true)
    _seq("sleep(50ms)", "select!", comment: "Pending", dashed: true)

    _gap()

    _seq("Main", "rx.recv()", comment: "send(Hello!)")
    _seq("rx.recv()", "select!", comment: "Ready(msg)", dashed: true)
    _note("right", "rx.recv() wins!")

    _gap()

    _seq("select!", "sleep(50ms)", comment: "drop", destroy-dst: true)
    _seq(
      "select!",
      "Task",
      comment: "Some(msg)",
      dashed: true,
      disable-dst: true,
    )
  })]

== Streams

Streams are runtime-agnostic asynchronous iterators:

```rs
use futures::stream::{self, StreamExt};

let stream = stream::iter(vec!['a', 'b', 'c']);

let mut stream = stream.enumerate();

assert_eq!(stream.next().await, Some((0, 'a')));
assert_eq!(stream.next().await, Some((1, 'b')));
assert_eq!(stream.next().await, Some((2, 'c')));
assert_eq!(stream.next().await, None);
```

See my project #link("https://github.com/wvhulle/clone-stream")

= Pitfalls


== Blocking executor

CPU blocking tasks will block the executor and prevent other tasks from being executed.

```rs
async fn sleep_ms(start: &Instant, id: u64, duration_ms: u64) {
    std::thread::sleep(std::time::Duration::from_millis(duration_ms));
    println!("future {id} finished after {}ms", start.elapsed().as_millis());
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    let start = Instant::now();
    let futures = (1..=10).map(|t| sleep_ms(&start, t, t * 10));
    join_all(futures).await;
}
```

#pause

#qa[What is a workaround?][Use async methods: `tokio::time::sleep` instead of `std::thread::sleep`]

== When to use parallelism


#slide[

  #table(
    columns: (auto, 1fr, 1fr),
    inset: 8pt,
    align: (center + horizon, left + horizon, left + horizon),
    stroke: 0.5pt,
    [*Aspect*], [*Threads (Parallelism)*], [*Async (Concurrency)*],
    [Use case],
    [CPU-bound tasks: heavy computation],
    [I/O-bound tasks: waiting for external resources],

    [Goal],
    [Utilize multiple CPU cores for true parallelism],
    [Handle many operations on single thread],

    [Examples],
    [Data processing, scientific computing, compilation, rendering],
    [Web servers, database queries, network clients, file I/O],

    [Overhead],
    [Higher: context switching, separate stacks],
    [Lower: cooperative yielding, shared stack],

    [When best],
    [Independent computations that can run simultaneously],
    [Many concurrent operations that mostly wait],
  )

]

== Deadlocks: Coffman Conditions

A deadlock occurs when four conditions are met simultaneously (Coffman conditions):

#table(
  columns: (auto, 1.5fr),
  inset: 8pt,
  align: (center + horizon, left + horizon),
  stroke: 0.5pt,
  [*Condition*], [*Description*],
  [Mutual exclusion], [Resources cannot be shared (only one thread at a time)],
  [Hold and wait], [Threads hold resources while waiting for others],
  [No preemption], [Resources cannot be forcibly taken from threads],
  [Circular wait], [Threads form a cycle waiting for each other's resources],
)

#pause

To prevent deadlock, break at least one condition:

- *Lock ordering*: Always acquire locks in the same order (breaks circular wait)
- *Timeout*: Release locks if waiting too long (breaks hold and wait)
- *Try-lock*: Use `try_lock()` instead of `lock()` (breaks hold and wait)

= Exercise: async philosophers

== Context

#slide[

  #set text(size: 0.7em)
  Simplified: 3 philosophers sitting around a table, 3 chopsticks between them.

  Rules:
  - Each philosopher needs 2 chopsticks (left and right) to eat
  - Eating takes time (must hold both chopsticks during eating)
  - All philosophers want to eat repeatedly

  #grid(columns: (1fr, 1fr), column-gutter: 1em)[

    #fletcher-diagram(
      spacing: (2em, 2em),
      node-stroke: 0.5pt,

      // Slide 1: Initial philosophers and chopsticks (P0, C0)
      node((0, 2.5), name: <p0>, [Socrates], shape: shapes.circle),
      node(
        (2.2, 1.2),
        name: <c0>,
        [Chopstick 0],
        shape: shapes.rect,
        stroke: gray,
      ),

      step(2),

      // Slide 2: Add remaining philosophers and chopsticks
      node((2.2, -1.2), name: <p1>, [Plato], shape: shapes.circle),
      node(
        (0, -2.5),
        name: <c1>,
        [Chopstick 1],
        shape: shapes.rect,
        stroke: gray,
      ),
      node((-2.2, -1.2), name: <p2>, [Aristotle], shape: shapes.circle),
      node(
        (-2.2, 1.2),
        name: <c2>,
        [Chopstick 2],
        shape: shapes.rect,
        stroke: gray,
      ),

      // Slide 2-3: Initial gray chopsticks (hide after P0 starts eating)
      ..until(
        3,
        node(
          (2.2, 1.2),
          name: <c0-gray>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: gray,
        ),
        node(
          (-2.2, 1.2),
          name: <c2-gray>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),

      step(3),

      // Slide 3: P0 eating (blue state)
      at(
        3,
        node(
          (0, 2.5),
          name: <p0eat>,
          [Socrates eating],
          shape: shapes.circle,
          stroke: blue,
          fill: blue.lighten(85%),
        ),
        edge(
          <p0eat>,
          <c0>,
          "->",
          label: [holds exclusively\ (mutual exclusion)],
          stroke: blue,
          bend: 45deg,
          label-pos: 0.6,
          label-side: right,
        ),
        edge(
          <p0eat>,
          <c2>,
          "->",
          label: [holds exclusively\ (mutual exclusion)],
          stroke: blue,
          bend: -25deg,
          label-pos: 0.7,
        ),
        node(
          (2.2, 1.2),
          name: <c0eat>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: blue,
          fill: blue.lighten(80%),
        ),
        node(
          (-2.2, 1.2),
          name: <c2eat>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: blue,
          fill: blue.lighten(80%),
        ),
      ),

      step(4),

      // Slide 4: Back to gray chopsticks after eating
      at(
        4,
        node(
          (2.2, 1.2),
          name: <c0-gray2>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: gray,
        ),
        node(
          (-2.2, 1.2),
          name: <c2-gray2>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),

      step(5),

      // Slide 5: All philosophers try to grab left (black edges, only this slide)
      at(
        5,
        edge(
          <p0>,
          <c2>,
          "->",
          label: [grabs left],
          stroke: (paint: black, thickness: 1.5pt),
          bend: -20deg,
          label-pos: 0.6,
          label-side: right,
        ),
        edge(
          <p1>,
          <c0>,
          "->",
          label: [grabs left],
          stroke: (paint: black, thickness: 1.5pt),
          bend: -20deg,
          label-pos: 0.4,
          label-side: right,
        ),
        edge(
          <p2>,
          <c1>,
          "->",
          label: [grabs left],
          stroke: (paint: black, thickness: 1.5pt),
          bend: -20deg,
          label-pos: 0.6,
        ),
      ),

      step(6),

      // Slide 6+: Successfully holding left chopsticks (green)
      between(
        6,
        10,
        edge(
          <p0>,
          <c2>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
        edge(
          <p1>,
          <c0>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
        edge(
          <p2>,
          <c1>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
        node(
          (2.2, 1.2),
          name: <c0-held>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
        node(
          (0, -2.5),
          name: <c1-held>,
          [Chopstick 1],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
        node(
          (-2.2, 1.2),
          name: <c2-held>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
      ),

      step(7),

      // Slide 7+: P0 wants right chopstick
      between(7, 10, edge(
        <p0>,
        <c0>,
        "-->",
        label: [wants C0],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      step(8),

      // Slide 8+: P1 wants right chopstick
      between(8, 10, edge(
        <p1>,
        <c1>,
        "-->",
        label: [wants C1],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      step(9),

      // Slide 9+: P2 wants right chopstick
      between(9, 10, edge(
        <p2>,
        <c2>,
        "-->",
        label: [wants C2],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      step(10),

      // Slide 10: Focus on Socrates' deadlock situation
      node(
        (0, 2.5),
        name: <p0-blocked>,
        [Socrates blocked!],
        shape: shapes.circle,
        stroke: red,
        fill: red.lighten(85%),
      ),
      // Highlight Socrates' green arrow to C2 (holds)
      edge(
        <p0-blocked>,
        <c2>,
        "->",
        label: [holds],
        stroke: (paint: green, thickness: 2pt),
        bend: -20deg,
        label-pos: 0.5,
      ),
      // Highlight Socrates' red arrow to C0 (wants)
      edge(
        <p0-blocked>,
        <c0>,
        "-->",
        label: [wants],
        stroke: (paint: red, thickness: 2pt),
        bend: 35deg,
        label-pos: 0.3,
      ),
      // Show Plato holding C0 (blocking Socrates)
      edge(
        <p1>,
        <c0>,
        "->",
        label: [held by Plato],
        stroke: (paint: green, thickness: 2pt),
        bend: -20deg,
        label-pos: 0.5,
      ),
    )][

    *Legend:*

    #table(
      columns: 2,
      stroke: none,
      inset: 6pt,
      align: (left, left),
      [#line(length: 2em, stroke: (paint: black, thickness: 1.5pt))],
      [Trying to grab],

      [#line(length: 2em, stroke: (paint: green, thickness: 2pt))],
      [Holding successfully],

      [#line(length: 2em, stroke: (
        paint: red,
        dash: "dashed",
        thickness: 1.5pt,
      ))],
      [Wants but blocked],
    )

    #pause

    *Socrates' perspective:*
    - Holds C2 (green)
    - Wants C0 (red dashed)
    - But C0 is held by Plato!

    #pause

    Same for Plato and Aristotle → circular wait → *Deadlock!*

    #pause

    #qa[Which Coffman condition should we break?][Circular wait: change lock order for one philosopher.]
  ]
]



== Assignment

Solve the "Dining Philosophers" problem with async tasks instead of threads.

- Revisit the standard thread-based version in `session6/examples/philosophers.rs`
- Complete exercise code in `session7/examples/philosophers.rs`.

Solutions are provided as `*-solution.rs` files.


== Additional bonus

#qa[Do we still need the asymmetry (the last philosopher switching hands)?][Yes, because all philosophers are still working in parallel in separate tasks, so we may have a deadlock.]




#qa[How to solve this problem with only a single async task? Do we still have deadlocks][No, since philosophers access sequentially.]



