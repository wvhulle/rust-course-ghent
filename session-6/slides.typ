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
#pagebreak()

== Important exercises

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
  node((2, 2), name: <access>, [accesses `data`], shape: shapes.rect, stroke: red),
  edge(<spawned>, <access>, "->"),
  edge(<access>, <drop>, "<-->", stroke: red, label: [race!], label-side: right),
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

  node((-1, 0), [main:], stroke: none),
  node((0, 0), name: <spawn>, [`spawn()`], shape: shapes.rect),
  node((1, 0), name: <work>, [...], shape: shapes.rect, stroke: gray),
  node((2, 0), name: <join>, [`join()?`], shape: shapes.rect, stroke: gray),
  node((3, 0), name: <drop>, [`data` dropped], shape: shapes.rect),

  edge(<spawn>, <work>, "->"),
  edge(<work>, <join>, "-->", stroke: gray),
  edge(<join>, <drop>, "-->", stroke: gray),
  edge(<work>, <drop>, "->", bend: -30deg),

  node((-1, 1.5), [spawned:], stroke: none),
  node((0.3, 1.5), name: <start1>, [start?], shape: shapes.pill, stroke: gray),
  node((1.5, 1.5), name: <run1>, [running], shape: shapes.pill),
  node((2.7, 1.5), name: <end1>, [end?], shape: shapes.pill, stroke: gray),

  edge(<spawn>, <start1>, "-->", stroke: gray, label: [sometime]),
  edge(<start1>, <run1>, "-->", stroke: gray),
  edge(<run1>, <end1>, "-->", stroke: gray, label: [sometime]),

  pause,
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
  node((1, 0), name: <scope>, [`thread::scope`], shape: shapes.rect, stroke: blue),
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
  node((2, 0), name: <barrier>, [barrier], shape: shapes.rect, stroke: blue, fill: blue.lighten(80%)),
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

  node((1, 0), name: <tx>, [`tx`], shape: shapes.rect),
  node((1.5, 0), name: <buf>, [buffer], shape: shapes.rect, width: 4em),
  node((2, 0), name: <rx>, [`rx`], shape: shapes.rect),

  edge(<t1>, <tx>, "->", label: [send]),
  edge(<tx>, <buf>, "->"),
  edge(<buf>, <rx>, "->"),
  edge(<rx>, <t2>, "->", label: [recv]),
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
  node((1, -0.5), name: <field1>, [`field1: String`], shape: shapes.rect, stroke: green),
  node((1, 0.5), name: <field2>, [`field2: i32`], shape: shapes.rect, stroke: green),

  edge(<mystruct>, <field1>, "->", label: [contains]),
  edge(<mystruct>, <field2>, "->", label: [contains]),

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
  edge(<field3>, <yesauto>, "->"),
  edge(<field4>, <yesauto>, "->", label: [all `Copy`]),
)




#qa[What are `unsafe` traits?][Traits that have safety invariants that the compiler cannot verify automatically. Implementing them incorrectly can lead to undefined behavior.]

You can implement `unsafe` traits manually when you know it is valid.

#pause

#warning[Implementing `unsafe` traits requires `unsafe` blocks. Using them as constraints does not.]

== Traits for thread safety

How does Rust know to forbid shared access across threads?

#pause


- `Send`: a type T is Send if it is safe to move a T across a thread boundary. #pause
- `Sync`: a type T is Sync if it is safe to move a &T across a thread boundary.

#pause

#info[Send and Sync are unsafe auto traits.]



== Send

A type T is `Send` if it is *safe to move a T value to another thread*.

#pause

Moving ownership entails:

- running destructor in the other thread
- accessing the value in the other thread
- taking mutable references to the value in the other thread

#pause


```rust
use std::thread;

fn main() {
    let data = vec![1, 2, 3]; // Vec<i32> is Send

    let handle = thread::spawn(move || {
        println!("Data in thread: {:?}", data);
        data.iter().sum::<i32>()
    });

    let result = handle.join().unwrap();
    println!("Sum: {}", result);
}
```

This compiles because `Vec<i32>` implements `Send`.

== Sync

A value of type `T` is `Sync` if and only if an immutable reference to `T` (`&T`) is `Send`.

In practice this means that it is safe to *access immutably from several threads in parallel*.


#corollary[A consequence of this is that if `T: !Sync` then `&T: !Send`.]
#pause
#proof[

  $
         #raw("&T") & <=> #raw("&&T") \
    T: #raw("Sync") & <=> #raw("&T"): #raw("Send")
  $
]



== Examples

=== Send + Sync


Most types you come across are Send + Sync:

- *Owned data, no interior mutability*: `i32`, `bool`, `String`, `Vec<T>`
#pause
- *Thread-safe shared ownership*: `Arc<T>` (atomic ref counting)
#pause
- *Hardware-supported atomics*: `AtomicBool`, `AtomicU8` (compare-and-swap, fetch-and-add)


#qa[When are the generic types such as `Vec<T>` Send + Sync][When the type parameters `T` are Send + Sync.]

=== Send + !Sync

These types can be moved to other threads, but cannot be shared via `&T`:

#pause

- *Non-thread-safe interior mutability*: `Cell<T>`, `RefCell<T>`
  - Allow mutation through `&T` without synchronization
  - Safe to own exclusively on one thread, unsafe to share references

#pagebreak()


=== !Send + Sync

These types are safe to access (via shared references) from multiple threads, but cannot be moved to another thread:

- *Lock guards*: `MutexGuard`, `RwLockReadGuard`, `RwLockWriteGuard`
  - Must be unlocked on the thread that acquired the lock (POSIX requirement)

#proposition[`MutexGuard<T: Sync>: !Send + Sync`]
#pause
#proof[
  *Part 1:* `MutexGuard<T: Sync>: !Send`

  $
             #raw("drop(MutexGuard)") & => #raw("Mutex::unlock()") \
              #raw("Mutex::unlock()") & => "must run on locking thread" \
    #raw("MutexGuard") : #raw("Send") & => #raw("drop") "can run on any thread" \
         therefore #raw("MutexGuard") & : !#raw("Send")
  $

  *Part 2:* `MutexGuard<T: Sync>: Sync`

  $
         #raw("MutexGuard<T>") & : #raw("Sync") \
    <=> #raw("&MutexGuard<T>") & : #raw("Send") \
                <=> #raw("&T") & : #raw("Send") quad "(deref coercion)" \
                         <=> T & : #raw("Sync") quad checkmark
  $
]

#pagebreak()

=== !Send + !Sync

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
  align: (x, y) => if x == 0 or y == 0 { center + horizon } else { left + horizon },
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

    #text(size: 0.85em, style: "italic")[Interior mutability: safe to move, not share]
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

== Arc

```rs
use std::sync::Arc; use std::thread;
#[derive(Debug)]
struct WhereDropped(Vec<i32>); /// A struct that prints which thread drops it.
impl Drop for WhereDropped {
    fn drop(&mut self) { println!("Dropped by {:?}",  thread::current().id()) }
}
fn main() {
    let v = Arc::new(WhereDropped(vec![10, 20, 30]));
    let mut handles = Vec::new();
    for i in 0..5 {
        let v = Arc::clone(&v);
        handles.push(thread::spawn(move || {
            // Sleep for 0-500ms.
            std::thread::sleep(std::time::Duration::from_millis(500 - i * 100));
            let thread_id = thread::current().id();
            println!("{thread_id:?}: {v:?}");
        }));
    }
    drop(v); // Now only the spawned threads will hold clones of `v`.
    // When the last spawned thread finishes, it will drop `v`'s contents.
    handles.into_iter().for_each(|h| h.join().unwrap());
}
```

#pagebreak()

#qa[What does `Arc<T>` stand for? ][Atomic Reference Counted.]

Atomic refers to the fact that the *reference count is updated using atomic operations*, making atomics (`AtomicUsize`) and `Arc<T>` safe to share between threads.

#qa[When does `Arc<T>` implement `Clone`? ][Always. Cloning an `Arc` only increments the reference count.]

#qa[When does `Arc<T>` implement `Send` and `Sync`? ][When `T` implements `Send` and `Sync`.]

== Mutex


Mutex<T> allows mutable access to T behind a read-only interface:

Get `&mut T` from an `&Mutex<T>` by taking the lock.

```rs
use std::sync::Mutex;

fn main() {
    let v = Mutex::new(vec![10, 20, 30]);
    println!("v: {:?}", v.lock().unwrap());

    {
        let mut guard = v.lock().unwrap();
        guard.push(40);
    }

    println!("v: {:?}", v.lock().unwrap());
}
```


#pause

Exercise: `examples/arc-mutex.rs`

#pagebreak()

#qa[The `lock()` returns a `Result<MutexGuard<T>, PoisonError>`. What is a `PoisonError`? ][Another thread panicked while holding the lock]


#qa[Why is `Mutex<T>: Sync` when `T: Send` (not `T: Sync`)?][The mutex ensures exclusive access - only one thread touches `T` at a time, so `T` doesn't need to support concurrent sharing.]

```rs
unsafe impl<T: ?Sized + Send> Sync for Mutex<T> {}
```



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



== Example


Typically Rust beginners will:

1. Wrap `T` in `Mutex::new(Arc::new(T))`
2. Clone the `Arc` to share ownership across threads
3. Lock the `Mutex` to get mutable access to `T` in each thread

There are some problems with this approach:

#pause

- *Deadlocks*: the guard returned by `.lock()` must be dropped and a costly operation (like I/O) performed while holding the lock. #pause
- *Coarse locking*: the whole data structure is locked, even when only a small part needs to be mutated. #pause
- *Global mutability*: all threads can mutate the data, making reasoning about the program harder.


#pause

My advice:

- Minimise or remove usage of `Arc<Mutex<T>>`.
- Use `RwLock<T>` when possible.
- Use `Atomic` types for simple shared counters/flags.



= Exercises


From Google:

- examples/philosophers.rs
- examples/link.rs
