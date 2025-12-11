#import "../template.typ": *
#import "@preview/cetz:0.4.2"


#show: rust-course.with(
  config-info(
    title: [Lecture 6: Parallel programming],
    subtitle: [Threads, channels and shared state],
    author: [Willem Vanhulle],
    date: [Tuesday December 9, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)



#title-slide()



Make sure you have already finished:

- session-5/tests/error-handling.rs


#set text(size: 0.8em)
= Threads


== Plain Threads
```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 0..10 {
            println!("Count in thread: {i}!");
            thread::sleep(Duration::from_millis(5));
        }
    });

    for i in 0..5 {
        println!("Main thread: {i}");
        thread::sleep(Duration::from_millis(5));
    }
}
```

#qa[What happens to the spawned thread?][Terminated by operating system when main thread exits. No destructors called.]

#pagebreak()

```rs
thread::spawn(|| {
    for i in 0..10 {   }
});

for i in 0..5 {
    println!("Main thread: {i}");
    thread::sleep(Duration::from_millis(5));
}
```

#qa[How can we ensure the spawned thread finishes?][Use `JoinHandle` returned by `thread::spawn` and call `join()` on it.]

```rs
fn main() {
  let handle = thread::spawn(|| {
    // thread code
  });
  // main thread code
  handle.join();
}
```



#pagebreak()

== Receiving data from threads

#qa[How can we get a return value from a thread?][The `JoinHandle` returns a `Result` with the thread's return value.]

```rust
fn main() {
    let handle = thread::spawn(|| {
        42
    });

    let result = handle.join().unwrap();
    println!("The answer is: {}", result);
}
```

#qa[What happens to the main thread if a spawned thread panics?][Nothing, the main thread continues executing.]


== Handling thread panics

If we don't join, we never see the panic.

#pause

If we don't handle the `Result` from `join()`, the panic is also ignored.

#pause

We need to check the `Result` from `join()` to see if the thread panicked:

```rust
fn main() {
    let handle = thread::spawn(|| {
        panic!("Thread panicked!");
    });
    let result = handle.join();
    match result {
        Ok(_) => println!("Thread completed successfully."),
        Err(e) => println!("Thread panicked: {:?}", e),
    }
}
```

#warning[You are responsible for handling panics in spawned threads! Rust will not do this for you.]

Exercise:

- examples/join-handle.rs

== Sending references to threads

Not all references can be sent to threads.

```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        let sum: i32 = data.iter().sum();
        println!("Sum: {sum}");
    });
    data.push(4); // modify while thread may be reading
    handle.join().unwrap();
}
```
#qa[What happens if a thread borrows data from the main thread?][Compilation error: closure may outlive the current function, but it borrows `data`.]

#fletcher-diagram(
  spacing: (3em, 2em),
  node-stroke: 0.5pt,
  node((0, 0), name: <main>, [`main` thread], shape: shapes.pill),
  node((2, 0), name: <spawned>, [spawned thread], shape: shapes.pill),

  node((0, 1), name: <data>, [`data: Vec`], shape: shapes.rect),
  node((0, 2), name: <drop>, [`data` dropped], shape: shapes.rect, stroke: red),

  edge(<main>, <data>, "->", label: [owns]),
  edge(<spawned>, <data>, "-->", stroke: red, label: [borrows?]),
  edge(<data>, <drop>, "->"),

  pause,
  node(
    (2, 2),
    name: <access>,
    [accesses `data`],
    shape: shapes.rect,
    stroke: red,
  ),
  edge(<spawned>, <access>, "->"),
  edge(
    <access>,
    <drop>,
    "<-->",
    stroke: red,
    label: [race!],
    label-side: right,
  ),
)


== Borrowing and threads (continued)

First attempt: ensure the thread finishes before `main` exits.

```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        let sum: i32 = data.iter().sum();
        println!("Sum: {sum}");
    });
    handle.join().unwrap();
    println!("Original: {:?}", data); // try to use after thread
}
```

#qa[Does adding `join()` fix the borrow error?][No. Rust cannot verify at compile time that `join` is called before `data` goes out of scope.]

#fletcher-diagram(
  spacing: (3em, 1.2em),
  node-stroke: 0.5pt,

  // Main thread timeline (always visible)
  node((-1, 0), [main:], stroke: none),
  node((0, 0), name: <spawn>, [`spawn()`], shape: shapes.rect),
  node((3, 0), name: <drop>, [`data` dropped], shape: shapes.rect),
  edge(<spawn>, <drop>, "->", bend: -30deg),

  pause,

  // Uncertain timing of join
  node((1, 0), name: <work>, [...], shape: shapes.rect, stroke: gray),
  node((2, 0), name: <join>, [`join()?`], shape: shapes.rect, stroke: gray),
  edge(<spawn>, <work>, "->"),
  edge(<work>, <join>, "-->", stroke: gray),
  edge(<join>, <drop>, "-->", stroke: gray),

  pause,

  // Spawned thread timeline
  node((-1, 1.5), [spawned:], stroke: none),
  node((0.3, 1.5), name: <start1>, [start?], shape: shapes.pill, stroke: gray),
  node((1.5, 1.5), name: <run1>, [running], shape: shapes.pill),
  node((2.7, 1.5), name: <end1>, [end?], shape: shapes.pill, stroke: gray),

  edge(<spawn>, <start1>, "-->", stroke: gray, label: [sometime]),
  edge(<start1>, <run1>, "-->", stroke: gray),
  edge(<run1>, <end1>, "-->", stroke: gray, label: [sometime]),

  pause,

  // Problem explanation
  node(
    (4, 0.8),
    name: <problem>,
    [References are *compile-time* constructs.\ Thread timing is *runtime* behavior.],
    stroke: red,
  ),
  edge(<end1>, <problem>, "-->", stroke: red),
  edge(<start1>, <problem>, "-->", stroke: red, bend: -20deg),
)




== Scoped threads

The problem: `thread::spawn` requires `'static` because the thread may outlive the caller.

```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        println!("Data: {:?}", data); // error: `data` does not live long enough
    });
    handle.join().unwrap();
}
```

#pause

Solution: `thread::scope` guarantees all spawned threads complete before the scope ends.

```rust
fn main() {
    let data = vec![1, 2, 3];
    thread::scope(|s| {
        s.spawn(|| println!("Data: {:?}", data)); // borrowing works!
    }); // all threads joined here automatically
    println!("Back in main: {:?}", data);
}
```

== Multiple scoped threads

```rust
fn main() {
    let mut data = vec![1, 2, 3];

    thread::scope(|s| {
        s.spawn(|| println!("Thread 1: {:?}", data)); // shared borrow
        s.spawn(|| println!("Thread 2: {:?}", data)); // shared borrow
    });

    data.push(4); // mutable access after scope ends
}
```


#fletcher-diagram(
  spacing: (5em, 1.5em),
  node-stroke: 0.5pt,

  node((0, 0), name: <before>, [main before scope], shape: shapes.rect),
  node(
    (1, 0),
    name: <scope>,
    [`thread::scope`],
    shape: shapes.rect,
    stroke: blue,
  ),
  node((3, 0), name: <end>, [scope ends], shape: shapes.rect, stroke: blue),
  node((4, 0), name: <after>, [main continues], shape: shapes.rect),

  edge(<before>, <scope>, "->"),
  edge(<end>, <after>, "->"),

  node((1.5, 1), name: <t1>, [thread 1], shape: shapes.pill),
  node((1.5, -1), name: <t2>, [thread 2], shape: shapes.pill),

  edge(<scope>, <t1>, "->"),
  edge(<scope>, <t2>, "->"),
  edge(<t1>, <end>, "->"),
  edge(<t2>, <end>, "->"),

  pause,
  node(
    (2, 0),
    name: <barrier>,
    [barrier],
    shape: shapes.rect,
    stroke: blue,
    fill: blue.lighten(80%),
  ),
  edge(<t1>, <barrier>, "->"),
  edge(<t2>, <barrier>, "->"),
  edge(<barrier>, <end>, "->", label: [all joined]),
)

== Moving to threads

In practice, scoped threads are not used very often.


The most common use case is to move ownership of data to the thread using the `move` keyword to transfer ownership at spawn time

```rs
fn main() {
    let data = String::from("hello");
    let handle = thread::spawn(move || {
        println!("Data: {data}"); // `data` moved into closure, now owned by thread
    });
    handle.join().unwrap();
}
```

Move can also be used for blocks (not closures):





== Review: what is `'static`?

In the past sessions we have seen that `T: 'static` means:

#definition[A type `T` is `'static` if it contains no non-`'static` references.]

Things that are `'static`:

- Owned data: `String`, `Vec<T>`, `Box<T>`, etc.
- `'static` references: `&'static str`, `&'static T`

Things that are not `'static`:

- References with shorter lifetimes: `&T`, `&'a T` where `'a` is not `'static`
- Types with non-`'static` fields: `&T`, `&'a T`, `Vec<&T>`, etc.

#pause

Strings are owned and without references, so they are `'static` and can be moved

#pause

=== Spawn function

The standard library spawn function looks like this (simplified):

```rs
fn spawn<F, T>(f: F) -> JoinHandle<T>
where
    F: FnOnce() -> T + 'static,
    T: 'static
```

(Similar for asynchronous spawns like `tokio::spawn`, see next session.)


= Channels

== What is a channel?

A channel is a communication primitive for passing messages between threads.

Under the hood: a thread-safe buffer (queue) in shared memory with:
- *Sender* (`tx`): pushes messages into the buffer
- *Receiver* (`rx`): pulls messages from the buffer

#fletcher-diagram(
  spacing: (6em, 2em),
  node-stroke: 0.5pt,
  node((0, 0), name: <t1>, [Thread 1], shape: shapes.pill),
  node((3, 0), name: <t2>, [Thread 2], shape: shapes.pill),

  node((1, 0), name: <tx>, [`tx`], shape: shapes.rect, stroke: gray),

  node((2, 0), name: <rx>, [`rx`], shape: shapes.rect, stroke: gray),
  edge(<t1>, <tx>, "->", label: [send]),
  edge(<tx>, <buf>, "->"),
  edge(<buf>, <rx>, "->"),
  edge(<rx>, <t2>, "->", label: [recv]),


  pause,
  node(enclose: (<tx>, <buf>, <rx>), name: <channel>, stroke: blue),

  node((1.5, 0), name: <buf>, [buffer], shape: shapes.rect, width: 4em),
)

#pause

Key properties:
- *Decouples* sender and receiver (no shared mutable state)
- *Asynchronous*: sender doesn't wait for receiver (unless bounded)
- *Ownership transfer*: messages are moved, not shared



== N-to-1 Channels

```rs
fn main() {
    let (tx, rx) = std::sync::mpsc::channel();
    std::thread::spawn(move || {
        let thread_id = std::thread::current().id();
        for i in 0..10 {
            tx.send(format!("Message {i}")).unwrap();
            println!("{thread_id:?}: sent Message {i}");
        }
        println!("{thread_id:?}: done");
    });
    std::thread::sleep(std::time::Duration::from_millis(100));

    for msg in rx.iter() {
        println!("Main: got {msg}");
    }
}
```

In an unbounded channel:

- `send()` never blocks (a kind of "asynchronous" behavior)
- returns a `Result::Err` when all receivers have been dropped

#definition[A channel is "closed" when all receivers have been dropped.]

== Bounded channels

If you don't want the channel buffer to grow indefinitely and cause memory overflow, you can use a bounded channel:

#pause

```rs
fn main() {
    let (tx, rx) = mpsc::sync_channel(3);

    thread::spawn(move || {
        let thread_id = thread::current().id();
        for i in 0..10 {
            tx.send(format!("Message {i}")).unwrap();
            println!("{thread_id:?}: sent Message {i}");
        }
        println!("{thread_id:?}: done");
    });
    thread::sleep(Duration::from_millis(100));

    for msg in rx.iter() {
        println!("Main: got {msg}");
    }
}
```
This channel provides an additional method `try_send()` that returns immediately with an error if the buffer is full.

== Exercises

- `examples/channel.rs`

= Send and Sync
== Marker Traits

#qa[What are auto traits?][The compiler will automatically derive them for your types as long as they only contain types that implement the auto trait.]

#fletcher-diagram(
  spacing: (3em, 2em),
  node-stroke: 0.5pt,

  node((0, 0), name: <mystruct>, [`MyStruct`], shape: shapes.rect),
  node(
    (1, -0.5),
    name: <field1>,
    [`field1: String`],
    shape: shapes.rect,
    stroke: green,
  ),
  node(
    (1, 0.5),
    name: <field2>,
    [`field2: i32`],
    shape: shapes.rect,
    stroke: green,
  ),

  edge(<mystruct>, <field1>, "->", label: [contains]),
  edge(<mystruct>, <field2>, "->", label: [contains]),

  pause,

  node((2, 0), name: <auto>, [`Copy`? No], shape: shapes.pill, stroke: red),
  edge(<field1>, <auto>, "->", label: [`!Copy`]),
  edge(<field2>, <auto>, "->", stroke: green, label: [`Copy`]),

  pause,
  node((0, 1.5), name: <mystruct2>, [`Point`], shape: shapes.rect),
  node((1, 1.2), name: <field3>, [`x: i32`], shape: shapes.rect, stroke: green),
  node((1, 1.8), name: <field4>, [`y: i32`], shape: shapes.rect, stroke: green),
  node((2, 1.5), name: <yesauto>, [`Copy`], shape: shapes.pill, stroke: green),

  edge(<mystruct2>, <field3>, "->"),
  edge(<mystruct2>, <field4>, "->"),


  pause,
  edge(<field3>, <yesauto>, "->"),
  edge(<field4>, <yesauto>, "->", label: [all `Copy`]),
)




#qa[What are `unsafe` traits?][Traits that have safety invariants that the compiler cannot verify automatically. Implementing them incorrectly can lead to undefined behavior.]

You can implement `unsafe` traits manually when you know it is valid.

#pause

#warning[Implementing `unsafe` traits requires `unsafe` blocks. Using them as constraints does not.]

== Send and Sync

#definition[
  - `Send`: safe to *move* `T` to another thread
  - `Sync`: safe to *share* `&T` across threads (i.e., `&T: Send`)
]

#fletcher-diagram(
  spacing: (6em, 2em),
  node-stroke: 0.5pt,

  node((0, 0.5), name: <t>, [`T`], shape: shapes.rect),


  node((2, 0.5), name: <thread2>, [Spawned thread], shape: shapes.pill),

  edge(<t>, <thread2>, "->", label: [`T: Send`], label-side: left),

  pause,
  node((0, 2), name: <reft>, [`&T`], shape: shapes.rect),
  node((1, 1.5), name: <thread1>, [Thread 1], shape: shapes.pill),
  node((1, 2.5), name: <thread2b>, [Thread 2], shape: shapes.pill),
  node((1, 3.5), name: <thread3>, [Thread 3], shape: shapes.pill),

  edge(<reft>, <thread1>, "->"),
  edge(<reft>, <thread2b>, "->", label: [`&T: Send`]),
  edge(<reft>, <thread3>, "->"),

  node((2, 2.5), name: <sync>, [`T: Sync`], shape: shapes.pill, stroke: blue),
  edge(<thread1>, <sync>, "->", stroke: blue),
  edge(<thread2b>, <sync>, "<=>", stroke: blue),
  edge(<thread3>, <sync>, "->", stroke: blue),
)

#info[Send and Sync are unsafe auto traits.]



== Send + Sync


Most types you come across are Send + Sync:

- *Owned data, no interior mutability*: `i32`, `bool`, `String`, `Vec<T>`
#pause
- *Thread-safe shared ownership*: `Arc<T>` (atomic ref counting)
#pause
- *Hardware-supported atomics*: `AtomicBool`, `AtomicU8` (compare-and-swap, fetch-and-add)


#qa[When are the generic types such as `Vec<T>` Send + Sync][When the type parameters `T` are Send + Sync.]

== Atomics

Atomics are low-level types for lock-free concurrent programming.

#pause

Two problems with normal memory operations:
- Compilers and CPUs may *reorder* instructions for optimization
- Read-modify-write (e.g., `x += 1`) is *not atomic* (multiple CPU instructions)

#pause

```rust
static mut DATA: u32 = 0;
static mut READY: bool = false;

fn thread1() { unsafe { DATA = 42; READY = true; } }
fn thread2() { unsafe { while !READY {} println!("{}", DATA); } } // might print 0!
```

CPU might execute `READY = true` before `DATA = 42`.


== Atomics (continued)

Solution: atomic operations with memory ordering guarantees.

```rust
use std::sync::atomic::{AtomicBool, AtomicU32, Ordering};

static DATA: AtomicU32 = AtomicU32::new(0);
static READY: AtomicBool = AtomicBool::new(false);

fn thread1() {
    DATA.store(42, Ordering::Release);
    READY.store(true, Ordering::Release);
}
fn thread2() {
    while !READY.load(Ordering::Acquire) {}
    println!("{}", DATA.load(Ordering::Acquire)); // guaranteed 42
}
```

#fletcher-diagram(
  spacing: (6em, 1.5em),
  node-stroke: 0.5pt,

  node((-0.7, 0), [Thread 1:], stroke: none),
  node((0, 0), name: <store1>, [`DATA.store(42, Release)`], shape: shapes.rect),
  node(
    (1, 0),
    name: <store2>,
    [`READY.store(true, Release)`],
    shape: shapes.rect,
  ),
  edge(<store1>, <store2>, "->"),

  node((-0.7, 1), [Thread 2:], stroke: none),
  node((0, 1), name: <spin>, [spinning...], shape: shapes.rect, stroke: gray),
  node(
    (1, 1),
    name: <load1>,
    [`READY.load(Acquire)` → true],
    shape: shapes.rect,
  ),
  node((2, 1), name: <load2>, [`DATA.load(Acquire)` → 42], shape: shapes.rect),
  edge(<spin>, <load1>, "->", stroke: gray),
  edge(<load1>, <load2>, "->"),

  edge(<store2>, <load1>, "-->", stroke: blue, label: [happens-before]),
)

The happens-before edge is on `READY` (same atomic, Release-store → Acquire-load).

This transitively makes `DATA.store` visible to `DATA.load`.

== Atomics: hardware support

Not all CPUs support all atomic operations natively.

#pause

- *Always supported*: `AtomicBool`, `AtomicU8`, `AtomicU16`, `AtomicU32`, `AtomicUsize`
- *64-bit only*: `AtomicU64` (not available on 32-bit targets)
- *Rare*: `AtomicU128` (only some x86-64 CPUs)

#pause

Check at compile time:

```rust
#[cfg(target_has_atomic = "64")]
use std::sync::atomic::AtomicU64;
```

#pause

If hardware doesn't support an atomic size, Rust either:
- Won't compile (type not available)
- Falls back to a lock-based implementation (slower)

#info[On modern x86-64 and ARM64, all common atomics are hardware-supported.]

#focus-slide[
  #image("images/locks.jpg")
]

== Send + !Sync

These types can be moved to other threads, but cannot be shared via `&T`:

#pause

- *Non-thread-safe interior mutability*: `Cell<T>`, `RefCell<T>`
  - Allow mutation through `&T` without synchronization
  - Safe to own exclusively on one thread, unsafe to share references



== !Send + Sync

These types are safe to access (via shared references) from multiple threads, but cannot be moved to another thread:

- *Lock guards*: `MutexGuard`, `RwLockReadGuard`, `RwLockWriteGuard`
  - Must be unlocked on the thread that acquired the lock (POSIX requirement)

#proposition[`MutexGuard<T: Sync>: !Send + Sync`]


== !Send + !Sync

These types are not thread-safe and cannot be moved to other threads:

#pause

- dereferences and has non-atomic count: `Rc<T>`
- considered unsafe in general `*const T`, `*mut T`

== Summary

#set text(size: 0.9em)
#table(
  columns: (auto, 1fr, 1fr),
  rows: (auto, auto, auto),
  inset: 12pt,
  align: (x, y) => if x == 0 or y == 0 { center + horizon } else {
    left + horizon
  },
  stroke: 0.5pt,
  table.header([], [*Sync*], [*!Sync*]),
  [*Send*],
  [
    `i32`, `bool`, `String`, `Vec<T>` \
    `Arc<T>`, `Mutex<T>`, `Atomic*`

    #text(size: 0.85em, style: "italic")[Safe to move and share]
  ],
  [
    `Cell<T>`, `RefCell<T>`

    #text(
      size: 0.85em,
      style: "italic",
    )[Interior mutability: safe to move, not share]
  ],

  [*!Send*],
  [
    `MutexGuard`, `RwLock*Guard`

    #text(size: 0.85em, style: "italic")[Thread-bound: safe to share, not move]
  ],
  [
    `Rc<T>`, `*const T`, `*mut T`

    #text(size: 0.85em, style: "italic")[Not thread-safe at all]
  ],
)


= Shared state

== Sharing data

The unsafe way to share data between threads is to use `static mut`:

```rs
static mut COUNTER: u32 = 0;
fn increment() {
    unsafe {
        COUNTER += 1;
    }
}
```
#pause

#fletcher-diagram(
  spacing: (7em, 1.5em),
  node-stroke: 0.5pt,

  node(
    (0.5, 1),
    name: <static>,
    [`static mut COUNTER`],
    shape: shapes.rect,
    stroke: red,
  ),
  pause,
  node((0, 0), name: <stack1>, [Stack (Thread 1)], shape: shapes.rect),
  edge(<stack1>, <static>, "->", stroke: red, label: [unsafe]),


  pause,
  node((1, 0), name: <stack2>, [Stack (Thread 2)], shape: shapes.rect),


  edge(<stack2>, <static>, "->", stroke: red, label: [unsafe]),
  pause,
  pause,
  node(
    (2, 1),
    name: <note>,
    [Shared memory,\ no synchronization!],
    stroke: red,
  ),
)

Disadvantages:

- Unsafe: requires `unsafe` blocks to access
- Needs to be initialized for the entire program lifetime


#pause

Solution:

1. Use reference counted variable (next slides) #pause
2. Use a lock to ensure exclusive access (later)

#pause

_(Notice that in this simple case we could just use an `AtomicU32` instead. This is just an example.)_

== Concept

#definition[`Arc<T>` = *Atomic Reference Counted* pointer for shared ownership across threads.]

#fletcher-diagram(
  spacing: (5em, 2em),
  node-stroke: 0.5pt,

  node((1, 0), name: <data>, [`T` (heap)], shape: shapes.rect, stroke: blue),
  node(
    (1, -0.5),
    name: <count>,
    [count: 3],
    shape: shapes.rect,
    stroke: blue,
    fill: blue.lighten(90%),
  ),

  node((0, 1), name: <t1>, [Thread 1], shape: shapes.pill),
  node((1, 1), name: <t2>, [Thread 2], shape: shapes.pill),
  node((2, 1), name: <t3>, [Thread 3], shape: shapes.pill),

  edge(<t1>, <data>, "->", label: [`Arc`]),
  edge(<t2>, <data>, "->", label: [`Arc`]),
  edge(<t3>, <data>, "->", label: [`Arc`]),
)

Key properties:

- `Arc::clone(&v)` increments ref count (atomic operation)
- When count reaches 0, data is dropped
- `Arc<T>: Send + Sync` when `T: Send + Sync`

#pagebreak()

=== Arc example

```rs
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);

    let handles: Vec<_> = (0..3).map(|i| {
        let data = Arc::clone(&data);
        thread::spawn(move || {
            println!("Thread {i}: {:?}", data);
        })
    }).collect();

    for h in handles { h.join().unwrap(); }
}
```

#pause

#qa[Who drops the data?][The last thread to finish (last `Arc` clone to go out of scope).]

#qa[Can we mutate `T` through `Arc<T>`?][No, `Arc` only provides shared access. Use `Arc<Mutex<T>>` for mutation.]

= Mutexes

== Mutex



Prevents race conditions on complex shared data using synchronisation.

#qa[How are you used to do data synchronisation in your favourite language?][...]

#definition[`Mutex<T>` = *Mutual Exclusion* lock for exclusive access to `T` across threads.]

#fletcher-diagram(
  spacing: (5em, 1.5em),
  node-stroke: 0.5pt,

  node((1, 0), name: <data>, [`T`], shape: shapes.rect, stroke: blue),
  node(
    (1, -0.5),
    name: <lock>,
    [lock],
    shape: shapes.rect,
    stroke: blue,
    fill: blue.lighten(90%),
  ),

  node((0, 1), name: <t1>, [Thread 1], shape: shapes.pill, stroke: green),
  node((1, 1), name: <t2>, [Thread 2], shape: shapes.pill, stroke: gray),
  node((2, 1), name: <t3>, [Thread 3], shape: shapes.pill, stroke: gray),

  edge(<t1>, <data>, "->", stroke: green, label: [holds lock]),
  edge(<t2>, <data>, "-->", stroke: gray, label: [waiting]),
  edge(<t3>, <data>, "-->", stroke: gray, label: [waiting]),
)

Key operations:

- `lock()` → blocks until lock acquired, returns `MutexGuard<T>`
- `MutexGuard` auto-releases lock when dropped (RAII)
- `Mutex<T>: Sync` when `T: Send`

#pagebreak()

=== Mutex example

```rs
use std::sync::Mutex;

fn main() {
    let counter = Mutex::new(0);

    {
        let mut guard = counter.lock().unwrap();
        *guard += 1;
    } // lock released here

    println!("Counter: {:?}", counter.lock().unwrap());
}
```

#pause

#qa[What is a `PoisonError`?][Another thread panicked while holding the lock. The data may be in an inconsistent state.]

#qa[Why does `Mutex<T>` require `T: Send` but not `T: Sync`?][The mutex guarantees only one thread accesses `T` at a time, so `T` doesn't need to support concurrent access.]

#pagebreak()

=== Arc + Mutex: shared mutable state

```rs
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));

    let handles: Vec<_> = (0..4).map(|_| {
        let counter = Arc::clone(&counter);
        thread::spawn(move || {
            let mut guard = counter.lock().unwrap();
            *guard += 1;
        })
    }).collect();

    for h in handles { h.join().unwrap(); }
    println!("Counter: {}", counter.lock().unwrap()); // 4
}
```

- `Arc` provides shared ownership across threads
- `Mutex` provides exclusive mutable access



== Interior mutability

#definition(
  title: [Interior mutability],
)[A type that allows mutation through a shared reference (`&T` → `&mut` inner).]

#pause

Types with interior mutability:

#table(
  columns: (1fr, auto, auto, 1.5fr),
  inset: 8pt,
  align: center + horizon,
  table.header([*Type*], [*Thread-safe?*], [*Checking*], [*Use case*]),
  [`Cell<T>`], [No], [Compile-time], [Simple values, `Copy` types],
  [`RefCell<T>`], [No], [Runtime (panics)], [Complex borrows, single-threaded],
  [`Mutex<T>`], [Yes], [Runtime (blocks)], [Exclusive access across threads],
  [`RwLock<T>`], [Yes], [Runtime (blocks)], [Many readers, few writers],
  [`Atomic*`], [Yes], [Hardware], [Counters, flags, lock-free],
)

#pause



== Deadlocks

#slide[
  The `Arc<Mutex<T>>` pattern is common but has drawbacks: forgetting to drop the guard before blocking operations

  #set text(size: 1.2em)
  #cetz-canvas(length: 1cm, {
    import draw: *

    // Timeline labels
    content((0, 0), [Thread 1])
    content((4, 0), [Thread 2])
    content((8, 0), text(fill: gray)[Time])

    // Vertical lifelines
    line((0, -0.5), (0, -8), stroke: gray)
    line((4, -0.5), (4, -8), stroke: gray)

    // Time arrow
    line(
      (7, -0.5),
      (7, -8),
      stroke: (dash: "dashed", paint: gray),
      mark: (end: ">"),
    )

    (pause,)
    // Thread 1 actions
    content((-1.5, -1.5), text(size: 0.8em)[`lock(A)`], anchor: "east")

    (pause,)

    rect((-0.3, -1.2), (0.3, -1.8), fill: green.lighten(70%), stroke: green)
    content((-1.5, -3), text(size: 0.8em)[holds A], anchor: "east")
    line((0, -1.8), (0, -5), stroke: green + 2pt)


    (pause,)


    // Thread 2 actions
    content((5.5, -2.5), text(size: 0.8em)[`lock(B)`], anchor: "west")

    (pause,)
    rect((-0.3, -5.2), (0.3, -5.8), fill: red.lighten(70%), stroke: red)
    content((5.5, -4), text(size: 0.8em)[holds B], anchor: "west")
    line((4, -2.8), (4, -6), stroke: green + 2pt)
    rect((3.7, -2.2), (4.3, -2.8), fill: green.lighten(70%), stroke: green)


    (pause,)


    content((-1.5, -5.5), text(size: 0.8em)[`lock(B)`], anchor: "east")


    (pause,)


    content((-1.5, -7), text(size: 0.8em)[blocked!], anchor: "east")
    line((0, -5.8), (0, -8), stroke: (
      paint: red,
      dash: "dashed",
      thickness: 2pt,
    ))

    (pause,)

    content((5.5, -6.5), text(size: 0.8em)[`lock(A)`], anchor: "west")

    (pause,)
    rect((3.7, -6.2), (4.3, -6.8), fill: red.lighten(70%), stroke: red)
    line((4, -6.8), (4, -8), stroke: (
      paint: red,
      dash: "dashed",
      thickness: 2pt,
    ))

    (pause,)

    content((5.5, -7.5), text(size: 0.8em)[blocked!], anchor: "west")

    (pause,)
    // Deadlock annotation
    rect((1.2, -7.3), (2.8, -7.9), fill: red.lighten(90%), stroke: red)
    content((2, -7.6), text(size: 0.8em, fill: red)[Deadlock])
  })

  #pause

]

== Origins of deadlocks

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

#pagebreak()

== Dining Philosophers deadlock

Simplified: 3 philosophers sitting around a table, 3 chopsticks between them.

Rules:
- Each philosopher needs 2 chopsticks (left and right) to eat
- Eating takes time (must hold both chopsticks during eating)
- All philosophers want to eat repeatedly

#grid(columns: (1fr, 1fr), column-gutter: 1em)[

  #set text(size: 0.7em)
  #fletcher-diagram(
    spacing: (3em, 3em),
    node-stroke: 0.5pt,

    // Slide 1: Initial philosophers and chopsticks (P0, C0)
    node((0, 2.5), name: <p0>, [Philosopher 0], shape: shapes.circle),
    node(
      (2.2, 1.2),
      name: <c0>,
      [Chopstick 0],
      shape: shapes.rect,
      stroke: gray,
    ),

    pause,

    // Slide 2: Add remaining philosophers and chopsticks
    node((2.2, -1.2), name: <p1>, [Philosopher 1], shape: shapes.circle),
    node(
      (0, -2.5),
      name: <c1>,
      [Chopstick 1],
      shape: shapes.rect,
      stroke: gray,
    ),
    node((-2.2, -1.2), name: <p2>, [Philosopher 2], shape: shapes.circle),
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

    pause,

    // Slide 3: P0 eating (blue state)
    ..at(
      3,
      node(
        (0, 2.5),
        name: <p0eat>,
        [P0 eating],
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

    pause,

    // Slide 4: Back to gray chopsticks after eating
    ..at(
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

    pause,

    // Slide 5: All philosophers try to grab left (black edges, only this slide)
    ..at(
      5,
      edge(
        <p0>,
        <c0>,
        "->",
        label: [grabs left],
        stroke: (paint: black, thickness: 1.5pt),
        bend: -20deg,
        label-pos: 0.6,
        label-side: right,
      ),
      edge(
        <p1>,
        <c1>,
        "->",
        label: [grabs left],
        stroke: (paint: black, thickness: 1.5pt),
        bend: -20deg,
        label-pos: 0.4,
        label-side: right,
      ),
      edge(
        <p2>,
        <c2>,
        "->",
        label: [grabs left],
        stroke: (paint: black, thickness: 1.5pt),
        bend: -20deg,
        label-pos: 0.6,
      ),
    ),

    pause,

    // Slide 6+: Successfully holding left chopsticks (green)
    ..between(
      6,
      10,
      edge(
        <p0>,
        <c0>,
        "->",
        stroke: (paint: green, thickness: 2pt),
        bend: -20deg,
      ),
      edge(
        <p1>,
        <c1>,
        "->",
        stroke: (paint: green, thickness: 2pt),
        bend: -20deg,
      ),
      edge(
        <p2>,
        <c2>,
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

    pause,

    // Slide 7+: P0 wants right chopstick
    ..between(7, 10, edge(
      <p0>,
      <c2>,
      "-->",
      label: [wants right],
      stroke: red,
      bend: 35deg,
      label-pos: 0.3,
    )),

    pause,

    // Slide 8+: P1 wants right chopstick
    ..between(8, 10, edge(
      <p1>,
      <c0>,
      "-->",
      label: [wants right],
      stroke: red,
      bend: 35deg,
      label-pos: 0.3,
    )),

    pause,

    // Slide 9+: P2 wants right chopstick
    ..between(9, 10, edge(
      <p2>,
      <c1>,
      "-->",
      label: [wants right],
      stroke: red,
      bend: 35deg,
      label-pos: 0.3,
    )),

    pause,

    // Slide 10: Show circular dependency (blocking reasons)
    edge(
      <c2>,
      <p2>,
      "<-",
      label: [C2 held by P2!],
      stroke: (paint: red, dash: "dotted", thickness: 2pt),
      bend: -35deg,
      label-pos: 0.5,
    ),
    edge(
      <c0>,
      <p0>,
      "<-",
      label: [C0 held by P0!],
      stroke: (paint: red, dash: "dotted", thickness: 1pt),
      bend: -35deg,
      label-pos: 0.5,
    ),
    edge(
      <c1>,
      <p1>,
      "<-",
      label: [C1 held by P1!],
      stroke: (paint: red, dash: "dotted", thickness: 2pt),
      bend: -35deg,
      label-pos: 0.5,
    ),
  )][
  #set text(size: 0.75em)

  *Legend:*

  #table(
    columns: 2,
    stroke: none,
    inset: 6pt,
    align: (left, left),
    [#line(length: 2em, stroke: (paint: black, thickness: 1.5pt))], [Trying to grab],

    [#line(length: 2em, stroke: (paint: green, thickness: 2pt))], [Holding successfully],

    [#line(length: 2em, stroke: (
      paint: red,
      dash: "dashed",
      thickness: 1.5pt,
    ))],
    [Wants but blocked],

    [#line(length: 2em, stroke: (paint: red, dash: "dotted", thickness: 2pt))], [Blocking reason],
  )

  #pause

  Deadlock! All four Coffman conditions met:
  - Mutual exclusion: each chopstick held by exactly one philosopher
  - Hold and wait: each philosopher holds left chopstick, waits for right
  - No preemption: philosophers cannot take chopsticks from each other
  - Circular wait: P0 needs C2 (held by P2) → P2 needs C1 (held by P1) → P1 needs C0 (held by P0)

  #pause

  #qa[Which Coffman condition should we break to solve this?][Circular wait is easiest: change the lock acquisition order for some philosophers.]

  #qa[How can we break the symmetry?][Make at least one philosopher acquire chopsticks in a different order than the others.]
]
#pagebreak()

Exercise:

- examples/philosophers.rs

Hints:
- All philosophers currently pick up left chopstick first, then right
- Breaking the circular pattern requires asymmetry
- You only need to change the behavior for one or more philosophers

Solutions are provided as `*-solution.rs` files.

== Best practices for Mutexes

Structure code to minimize shared mutable state in mutexes.

Alternatives:

- Use `RwLock<T>` for many readers, few writers
- Use `Atomic*` types for simple counters/flags


If really necessary:

- Use channels for *one-directional flow* (but they are also hard to maintain)

One more exercise:

- `examples/link.rs` (you need to have openssl installed, use the `flake.nix` or your package manager)


Solutions are provided as `*-solution.rs` files.
