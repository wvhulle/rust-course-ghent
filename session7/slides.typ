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

      - Requires custom promise and awaitable types
      - Low-level control over suspension
      - Flexible but verbose
      - Coroutine frame heap-allocated (optimizable)
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

      - Compiler automatically generates `Future` trait
      - High-level syntax with `.await`
      - Ecosystem provides runtime and utilities
      - State machine stack-allocated by default
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


== Simplest `Future`

The simplest future is an `Option`.


```rs
#[must_use = "futures do nothing unless you `.await` or poll them"]
pub struct Ready<T>(Option<T>);

impl<T> Future for Ready<T> {
    type Output = T;

    fn poll(mut self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<T> {
        Poll::Ready(self.0.take().expect("Ready polled after completion"))
    }
}
```

#pause

Not a very interesting future of course!

#qa[Name a few "real" (also called leaf) futures][...]

== More realistic `JoinHandle`

One common type implementing `Future` is a Tokio `JoinHandle`:

```rs
use tokio::task;

let join = task::spawn(async {
    panic!("something bad happened!")
});

// The returned result indicates that the task failed.
assert!(join.await.is_err());
```

== Spawning

Spawning creates a new task that runs concurrently with the spawner.

Use spawning when tasks can progress independently:

```rs
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:8080").await.unwrap();
    loop {
        let (socket, addr) = listener.accept().await.unwrap();
        // Spawn a new task for each connection
        tokio::spawn(async move {
            handle_client(socket, addr).await;
        });
    }
}
```

#pause

Each connection is handled independently without blocking the server from accepting new connections.


#focus-slide[
  #image("images/inception.jpg")
]

== Avoid spawn-ception

#warning[Spawning tasks from within spawned tasks creates hard-to-debug complexity.]

Common anti-pattern:

```rs
tokio::spawn(async {
    // Some work
    tokio::spawn(async {  // Nested spawn!
        // More work
        tokio::spawn(async { /* ... */ })
    })
})
```

#pause

*Recommendation:* Spawn once at application boundaries:
- Spawn tasks at the top level (e.g., per incoming request)
- Use regular async functions and `.await` for sequential steps
- Only spawn when you need true concurrent execution


= Rust's async implementation


#focus-slide[
  #image("images/packt.webp")
]
== State machine

Rust transforms async functions into state machines that implement `Future`.

#pause

Key characteristics:

- Calling an async function constructs and returns a future
- Does not execute immediately (lazy)
- Tracks progress through suspension points

#pause

The state machines are allocated on the stack by default. Once allocated, the async runtime never moves the state machine to a different memory location.

#definition[Rust uses *stackless coroutines*: async functions don't have their own call stack. Instead, they compile to state machines that store only the data needed at suspension points, enabling zero-cost abstractions.]

== Stackless vs Stackful

#slide[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    [
      *Stackful (Go, goroutines)*

      #fletcher-diagram(
        spacing: (1.2em, 2em),
        node-stroke: 1pt,
        // Task 1
        node((0, 0), [Task], shape: shapes.rect, name: <c1>),
        node(
          (0, 1),
          [Full \ call \ stack],
          fill: red.lighten(80%),
          name: <s1>,
          shape: shapes.rect,
        ),
        node((0, 2), [8KB-2MB], fill: red.lighten(60%), name: <sz1>),
        edge(<c1>, <s1>, "->", label: text(size: 0.6em)[owns]),
        edge(<s1>, <sz1>, "->", text(size: 0.6em)[estimate \ pre-allocated]),

        pause,

        // Task 2
        node((1, 0), [Task], shape: shapes.rect, name: <c2>),
        node(
          (1, 1),
          [Full \ call \ stack],
          fill: red.lighten(80%),
          name: <s2>,
          shape: shapes.rect,
        ),
        node((1, 2), [8KB-2MB], fill: red.lighten(60%), name: <sz2>),
        edge(<c2>, <s2>, "->", label: text(size: 0.6em)[owns]),
        edge(<s2>, <sz2>, "->"),

        pause,

        // Task 3
        node((2, 0), [Task], shape: shapes.rect, name: <c3>),
        node(
          (2, 1),
          [Full \ call \ stack],
          fill: red.lighten(80%),
          name: <s3>,
          shape: shapes.rect,
        ),
        node((2, 2), [8KB-2MB], fill: red.lighten(60%), name: <sz3>),
        edge(<c3>, <s3>, "->", label: text(size: 0.6em)[owns]),
        edge(<s3>, <sz3>, "->"),
      )

      #pause

      10K tasks = 80MB-20GB
    ],
    [
      *Stackless (Rust async)*

      #fletcher-diagram(
        spacing: (1.2em, 2em),
        node-stroke: 1pt,
        // Future 1
        node((0, 0), [Future], shape: shapes.rect, name: <f1>),
        node(
          (0, 1),
          [State \ machine],
          fill: green.lighten(80%),
          name: <st1>,
          shape: shapes.rect,
        ),
        node((0, 2), [varies], fill: green.lighten(60%), name: <sz1>),
        edge(<f1>, <st1>, "->", label: text(size: 0.6em)[is]),
        edge(<st1>, <sz1>, "->", text(size: 0.6em)[tightly \ pre-allocated]),

        pause,

        // Future 2
        node((1, 0), [Future], shape: shapes.rect, name: <f2>),
        node(
          (1, 1),
          [State \ machine],
          fill: green.lighten(80%),
          name: <st2>,
          shape: shapes.rect,
        ),
        node((1, 2), [varies], fill: green.lighten(60%), name: <sz2>),
        edge(<f2>, <st2>, "->", label: text(size: 0.6em)[is]),
        edge(<st2>, <sz2>, "->"),

        pause,

        // Future 3
        node((2, 0), [Future], shape: shapes.rect, name: <f3>),
        node(
          (2, 1),
          [State \ machine],
          fill: green.lighten(80%),
          name: <st3>,
          shape: shapes.rect,
        ),
        node((2, 2), [varies], fill: green.lighten(60%), name: <sz3>),
        edge(<f3>, <st3>, "->", label: text(size: 0.6em)[is]),
        edge(<st3>, <sz3>, "->"),
      )

      #pause

      10K tasks = ~1MB
    ],
  )

  #pause

  *Key difference:* Stackful tasks allocate a fixed-size stack (pre-allocated for deep call chains), while stackless state machines allocate only the exact space needed for live variables at each suspension point.
]

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


== Coroutines

Async functions in Rust are coroutines that yield nothing.


#definition[Coroutines are a type of functions that may yield intermediate results and can be resumed.]



#text(size: 0.8em)[
  ```rs
  fn main() {
      let mut coroutine = #[coroutine] || {
          yield 1;
          return "foo"
      };

      match Pin::new(&mut coroutine).resume(()) {
          CoroutineState::Yielded(1) => {}
          _ => panic!("unexpected value from resume"),
      }
      match Pin::new(&mut coroutine).resume(()) {
          CoroutineState::Complete("foo") => {}
          _ => panic!("unexpected value from resume"),
      }
  }
  ```]

= Ecosystem

== Async runtimes

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2em,

  [
    A runtime provides support for:

    - *reactor*: reacting to IO events asynchronously
    - *executor*: pushing futures forward  concurrently

    #pause

    Rust does not have a "built-in" runtime, but several options are available:

    - `futures` offers a bare bones executor #link("https://docs.rs/futures/latest/futures/executor/struct.ThreadPool.html")[`ThreadPool`]
    - `tokio` offers a `Runtime` with reactor included (supplies "time" etc.)


    #pause

    #warning[Embassy is not a traditional async run-time, built for small embedded devices. It has no allocator (no heap).]
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
#[tokio::main] // Optional macro to start async multi-threaded runtime.
async fn main() {
    tokio::spawn(count_to(10));
    for i in 0..5 {
        println!("Main task: {i}");
        time::sleep(time::Duration::from_millis(5)).await;
    }
}
```

Async tasks are also aborted if not awaited in main.


== Tasks

A task is a top-level future spawned into the runtime.

#pause

#warning[In multi-threaded runtimes, tasks must be `Send + 'static` and may be moved between worker threads by the work-stealing scheduler.]



```rs
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


#pagebreak()



#slide[
  #set text(size: 0.8em)
  #fletcher-diagram(
    spacing: (6em, 2.5em),
    node-stroke: 1pt,
    // Runtime box
    node(
      (1.5, 0),
      [*Tokio Runtime*],
      stroke: 2pt,
      shape: shapes.rect,
      name: <runtime>,
    ),

    pause,

    // Executor
    node(
      (0, 1),
      [*Executor*],
      fill: blue.lighten(80%),
      stroke: blue + 1pt,
      shape: shapes.rect,
      name: <executor>,
    ),

    pause,

    // Global queue
    node(
      (0, 2),
      [Global \ Queue],
      fill: purple.lighten(80%),
      stroke: purple + 1pt,
      shape: shapes.rect,
      name: <global>,
    ),

    pause,

    // Worker Threads with local queues
    node((-1, 3), [Thread 1], stroke: 1pt, shape: shapes.circle, name: <th1>),
    node(
      (-0.5, 4),
      [Local \ Queue],
      fill: yellow.lighten(80%),
      stroke: 1pt,
      name: <lq1>,
    ),

    pause,

    node((1.5, 3), [Thread 2], stroke: 1pt, shape: shapes.circle, name: <th2>),
    node(
      (1, 4),
      [Local \ Queue],
      fill: yellow.lighten(80%),
      stroke: 1pt,
      name: <lq2>,
    ),

    pause,

    // Reactor
    node(
      (3, 1),
      [*Reactor*],
      fill: green.lighten(80%),
      stroke: green + 1pt,
      shape: shapes.rect,
      name: <reactor>,
    ),

    pause,

    // Tasks in queues
    node((-0.2, 3), [Task 1], stroke: 1pt, shape: shapes.rect, name: <t1>),
    node((-0.5, 5), [Task 2], stroke: 1pt, shape: shapes.rect, name: <t2>),
    node((1, 5), [Task 3], stroke: 1pt, shape: shapes.rect, name: <t3>),
    node((0.2, 3), [Task 4], stroke: 1pt, shape: shapes.rect, name: <t4>),

    pause,

    // I/O Events
    node(
      (3, 3),
      [I/O Events],
      stroke: 1pt,
      shape: shapes.hexagon,
      name: <io>,
    ),

    pause,

    // Edges from executor to global queue
    edge(
      <executor>,
      <global>,
      "->",
      stroke: 2pt + purple,
      label: text(size: 0.7em)[push tasks],
    ),

    pause,

    // Edges from global queue to local queues
    edge(
      <global>,
      <lq1>,
      "->",
      stroke: 1pt + purple,
      label: text(size: 0.6em)[steal],
      bend: -20deg,
    ),
    edge(<global>, <lq2>, "->", stroke: 1pt + purple, label: text(
      size: 0.6em,
    )[steal]),

    pause,

    // Edges showing work stealing between local queues
    edge(
      <lq2>,
      <lq1>,
      "<->",
      stroke: 1pt + orange,
      label: text(size: 0.6em)[work-steal],
      bend: 20deg,
    ),

    pause,

    // Edges from threads to local queues
    edge(<th1>, <lq1>, "->", stroke: 2pt + green, label: text(
      size: 0.7em,
    )[polls]),
    edge(<th2>, <lq2>, "->", stroke: 2pt + green),

    pause,

    // Tasks stored in queues
    edge(<global>, <t1>, "->", label: text(size: 0.6em)[stores]),
    edge(<global>, <t4>, "->", label: text(size: 0.6em)[stores]),
    edge(<lq1>, <t2>, "->", label: text(size: 0.6em)[stores]),
    edge(<lq2>, <t3>, "->", label: text(size: 0.6em)[stores]),

    pause,

    // Edges from I/O to reactor
    edge(<io>, <reactor>, "-|>", label: text(size: 0.6em)[notify]),

    pause,

    // Edge between reactor and executor
    edge(
      <reactor>,
      <executor>,
      "<->",
      label: text(size: 0.6em)[wake],
      // bend: -20deg,
    ),
  )
]

== Exercise

#info[
  An async block like `async move {}` is like a scope block that may contain awaits.
]

Refactor `session7/examples/tasks.rs`:

- Create async helper function from async block
- Improve error handling

= Common async datatypes and functions



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

== Joining two futures

When you need to wait for exactly two futures concurrently, use the `join!` macro:

```rs
use tokio::join;

async fn fetch_user(id: u32) -> User { /* ... */ }
async fn fetch_posts(user_id: u32) -> Vec<Post> { /* ... */ }

#[tokio::main]
async fn main() {
    let (user, posts) = join!(
        fetch_user(1),
        fetch_posts(1)
    );
    println!("User: {user:?}, Posts: {}", posts.len());
}
```

#pause

Unlike sequential awaits, both futures run concurrently. If one fails, both are awaited before returning the error.

#pagebreak()

*Exercise:* Refactor `session7/examples/join.rs` to use `join!` instead of sequential awaits.

== Joining an iterable

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

#pagebreak()

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

#text(size: 0.9em)[
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

    _seq(
      "select!",
      "Task",
      comment: "Some(msg)",
      dashed: true,
      disable-dst: true,
    )
    _note("left", "sleep future dropped")
  })]


#pagebreak()

== Select exercise

Use `tokio::select!` to implement a timeout mechanism for a long-running operation.

```rs
async fn fetch_data() -> String {
    sleep(Duration::from_secs(5)).await;
    "Data fetched".to_string()
}

#[tokio::main]
async fn main() {
    // TODO: Use select! to race fetch_data() against a 2-second timeout
    // Print "Success: {data}" if fetch completes
    // Print "Timeout!" if the timeout occurs first
}
```

#pause

*Exercise:* Complete `session7/examples/select.rs` to implement timeout logic using `tokio::select!`.


== Async `Mutex`

Prefer `std::sync::Mutex` by default - it's faster and cheaper for short critical sections.

#pause

Use `tokio::sync::Mutex` only when you need to hold the lock across `.await` points:

```rs
// Won't compile: std::sync::MutexGuard is not Send
let guard = std_mutex.lock().unwrap();
some_async_operation().await; // Error!
drop(guard);
```

```rs
// Works: tokio::sync::MutexGuard is Send
let guard = tokio_mutex.lock().await;
some_async_operation().await; // OK
drop(guard);
```

#pause

The `Send` requirement exists because futures may move between threads at await points. `std::sync::MutexGuard` is deliberately not `Send` to prevent deadlocks.

#pause

*Alternative:* Consider using message passing (channels) instead of shared mutable state.

= Streams

#focus-slide[
  #image("images/signal.webp")
]


== Like iterators

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

== Awaiting many futures

The `FuturesUnordered` is a `Stream` that yields results as futures complete (in completion order, not insertion order).

#pause

```rs
async fn process_item(id: u32) -> String {
    sleep(Duration::from_millis(100 * id as u64)).await;
    format!("Processed item {id}")
}

async fn main() {
    let mut futures = FuturesUnordered::new();

    for i in 1..=5 { futures.push(process_item(i)); }

    while let Some(result) = futures.next().await {
        println!("{result}");
    }
}
```



== Stream operators

You can also apply "adapters" to streams (similar to iterator adapters):

```rs
#[tokio::main]
async fn main() {
    let stream = stream::iter(1..=10);

    let result: Vec<_> = stream
        .filter(|x| futures::future::ready(x % 2 == 0))
        .map(|x| x * 2)
        .collect()
        .await;

    println!("{result:?}"); // [4, 8, 12, 16, 20]
}
```

#pause

Common adapters: `map`, `filter`, `filter_map`, `fold`, `take`, `skip`, `zip`, `chain`

See: Futures `StreamExt` trait and my project #link("https://github.com/wvhulle/clone-stream")


== Stream exercise

Process a stream of numbers using adapters to:
1. Filter out numbers less than 5
2. Square each number
3. Take only the first 3 results

```rs
use futures::future::ready;
use futures::stream::{self, StreamExt};

#[tokio::main]
async fn main() {
    let numbers = stream::iter(1..=20);

    // TODO: Chain filter, map, and take adapters
    // to get the first 3 squares of numbers >= 5
    // Use ready() in the filter predicate

    let result: Vec<_> = numbers.collect().await;
    println!("{result:?}");
}
```

#pause

*Exercise:* Complete `session7/examples/streams.rs` to transform the stream using adapters.

= Pitfalls


== Blocking operations prevent context switching

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

#qa[While `std::thread::sleep` blocks, the executor cannot poll other tasks. How to run them concurrently?][Use async-aware operations like `tokio::time::sleep` that yield control back to the executor, allowing context switching.]

== Async for limited parallelism

#warning[Async tasks run on a limited thread pool and don't provide true parallelism for CPU-bound work.]

Async is designed for I/O concurrency, not CPU parallelism:

- Spawning 10,000 async tasks doesn't create 10,000 workers
- Tasks execute sequentially on the available thread pool
- CPU-bound work sees no benefit from async spawning

#pause

*Recommendation:* If there's no real I/O waiting:
- Use a small number of OS threads instead (`std::thread` or `rayon`)
- Match thread count to CPU cores for optimal performance
- Reserve async for coordinating I/O operations
== Pinning too much

The compiler may tell you to use `Box::pin` to pin futures to the heap.


#grid(
  columns: 2,
  gutter: 1em,
  [
    *Heap pinning (avoid in hot paths):*
    ```rs
    loop {
        let fut = Box::pin(async {
            process().await
        });
        tokio::select! {
            r = fut => handle(r),
            _ = shutdown() => break,
        }
    }
    ```
  ],
  [
    *Stack pinning (zero-cost):*
    ```rs
    use tokio::pin;
    loop {
        let fut = async {
            process().await
        };
        pin!(fut);
        tokio::select! {
            r = fut => handle(r),
            _ = shutdown() => break,
        }
    }
    ```
  ],
)

Use `Box::pin` for collections or return values, `pin!` for hot paths, `pin_project` for custom structs.

== Forget handling deadlocks

Asynchronous code is still susceptible to deadlocks.

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

      jump(2),

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
      only(
        "1-3",
        node(
          (2.2, 1.2),
          name: <c0-gray>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),
      only(
        "1-3",
        node(
          (-2.2, 1.2),
          name: <c2-gray>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),

      jump(3),

      // Slide 3: P0 eating (blue state)
      only(
        "3",
        node(
          (0, 2.5),
          name: <p0eat>,
          [Socrates eating],
          shape: shapes.circle,
          stroke: blue,
          fill: blue.lighten(85%),
        ),
      ),
      only(
        "3",
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
      ),
      only(
        "3",
        edge(
          <p0eat>,
          <c2>,
          "->",
          label: [holds exclusively\ (mutual exclusion)],
          stroke: blue,
          bend: -25deg,
          label-pos: 0.7,
        ),
      ),
      only(
        "3",
        node(
          (2.2, 1.2),
          name: <c0eat>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: blue,
          fill: blue.lighten(80%),
        ),
      ),
      only(
        "3",
        node(
          (-2.2, 1.2),
          name: <c2eat>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: blue,
          fill: blue.lighten(80%),
        ),
      ),

      jump(4),

      // Slide 4: Back to gray chopsticks after eating
      only(
        "4",
        node(
          (2.2, 1.2),
          name: <c0-gray2>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),
      only(
        "4",
        node(
          (-2.2, 1.2),
          name: <c2-gray2>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: gray,
        ),
      ),

      jump(5),

      // Slide 5: All philosophers try to grab left (black edges, only this slide)
      only(
        "5",
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
      ),
      only(
        "5",
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
      ),
      only(
        "5",
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

      jump(6),

      // Slide 6+: Successfully holding left chopsticks (green)
      only(
        "6-10",
        edge(
          <p0>,
          <c2>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
      ),
      only(
        "6-10",
        edge(
          <p1>,
          <c0>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
      ),
      only(
        "6-10",
        edge(
          <p2>,
          <c1>,
          "->",
          stroke: (paint: green, thickness: 2pt),
          bend: -20deg,
        ),
      ),
      only(
        "6-10",
        node(
          (2.2, 1.2),
          name: <c0-held>,
          [Chopstick 0],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
      ),
      only(
        "6-10",
        node(
          (0, -2.5),
          name: <c1-held>,
          [Chopstick 1],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
      ),
      only(
        "6-10",
        node(
          (-2.2, 1.2),
          name: <c2-held>,
          [Chopstick 2],
          shape: shapes.rect,
          stroke: green,
          fill: green.lighten(80%),
        ),
      ),

      jump(7),

      // Slide 7+: P0 wants right chopstick
      only("7-10", edge(
        <p0>,
        <c0>,
        "-->",
        label: [wants C0],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      jump(8),

      // Slide 8+: P1 wants right chopstick
      only("8-10", edge(
        <p1>,
        <c1>,
        "-->",
        label: [wants C1],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      jump(9),

      // Slide 9+: P2 wants right chopstick
      only("9-10", edge(
        <p2>,
        <c2>,
        "-->",
        label: [wants C2],
        stroke: red,
        bend: 35deg,
        label-pos: 0.3,
      )),

      jump(10),

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



= Exercise: broadcast chat application

== Overview

In this exercise, we want to use our new knowledge to implement a broadcast chat application. We have a chat server that the clients connect to and publish their messages. The client reads user messages from the standard input, and sends them to the server. The chat server broadcasts each message that it receives to all the clients.

For this, we use a broadcast channel on the server, and tokio_websockets for the communication between the client and the server.


#pagebreak()

#align(center)[
  #fletcher.diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    node((0, 0), [Client 1 \ stdin], shape: rect, name: <c1>),
    node((0, 2), [Client 2 \ stdin], shape: rect, name: <c2>),
    node((0, 4), [Client 3 \ stdin], shape: rect, name: <c3>),
    node(
      (3, 2),
      [Server \ Broadcast \ Channel],
      shape: rect,
      width: 2.5cm,
      name: <server>,
    ),
    node((6, 0), [Client 1 \ stdout], shape: rect, name: <c1out>),
    node((6, 2), [Client 2 \ stdout], shape: rect, name: <c2out>),
    node((6, 4), [Client 3 \ stdout], shape: rect, name: <c3out>),
    edge(<c1>, <server>, "->", [WebSocket], label-side: left),
    edge(<c2>, <server>, "->", [WebSocket], label-side: left),
    edge(<c3>, <server>, "->", [WebSocket], label-side: left),
    edge(<server>, <c1out>, "->", [Broadcast], label-side: right),
    edge(<server>, <c2out>, "->", [Broadcast], label-side: right),
    edge(<server>, <c3out>, "->", [Broadcast], label-side: right),
  )
]

== APIs

You are going to need the following functions from tokio and tokio_websockets. Spend a few minutes to familiarize yourself with the API.

From the `futures` (or `futures-util`) crate:

- StreamExt::next() implemented by WebSocketStream: for asynchronously reading messages from a Websocket Stream.
- SinkExt::send() implemented by WebSocketStream: for asynchronously sending messages on a Websocket Stream.

Specific to Tokio:

- Lines::next_line(): for asynchronously reading user messages from the standard input. #link("https://docs.rs/tokio/latest/tokio/io/struct.Lines.html#method.next_line")
- Sender::subscribe(): for subscribing to a broadcast channel. #link("https://docs.rs/tokio/latest/tokio/sync/broadcast/struct.Sender.html#method.subscribe")


== Binaries

Normally in a Cargo project, you can have only one binary, and one src/main.rs file.


In this project, we need two binaries:one for the client, and one for the server.


_You could potentially make them two separate Cargo projects, but we are going to put them in a single Cargo project with two binaries._


For this to work, the client and the server code are in session7/src/bin.

Run the server with:

```bash
cargo run --bin server
```
and the client with:
```bash
cargo run --bin client
```

== Tasks

=== Server

Implement the `handle_connection` function in src/bin/server.rs.


Hint: Use `tokio::select!` for concurrently performing two tasks in a continuous loop:

- One task receives messages from the client and broadcasts them.
- The other sends messages received by the server to the client.

=== Client

Complete the main function in src/bin/client.rs.


Hint: As before, use tokio::select! in a continuous loop for concurrently performing two tasks:
1. reading user messages from standard input and sending them to the server, and
2. receiving messages from the server, and displaying them for the user.

Optional: Once you are done, change the code to broadcast messages to all clients, but the sender of the message.
