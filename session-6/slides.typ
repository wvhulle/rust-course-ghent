
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



= Remarks previous sessions


== Rust tooling

Open the standard library docs:

```bash
rustup doc --std
```

#pause

Pinning Rust version in `rust-toolchain.toml`:

```toml
[toolchain]
channel = "nightly-2025-12-08"
components = ["rustfmt", "clippy", "rust-analyzer"]
```

#pause

Installing nightly Rust binaries from crates.io:

```bash
rustup update nightly
rustup toolchain install nightly --component rustc-dev rust-src llvm-tools
cargo +nightly install ferrous-owl
```

Add `~/.cargo/bin` to your `PATH` if not already done.

Upgrading: `cargo +nightly install ferrous-owl`.

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

Exercise:

- examples/threads1.rs
- examples/threads2.rs

== Borrowing and threads

Sending references to threads:

```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        println!("Data: {:?}", data);
    });
}
```
#qa[What happens if you want a thread to borrow data from the main thread?][Compilation error: data may not live long enough. Use `move` keyword to transfer ownership.]

#pause
```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        println!("Data: {:?}", data);
    });
    handle.join().unwrap();
}
```

#qa[What happens if you add a join?][Same error. Rust cannot verify `join` is called before `data` goes out of scope (at compile time).]

== Scoped threads

```rust
fn main() {
    let data = vec![1, 2, 3];
    let handle = thread::spawn(|| {
        println!("Data: {:?}", data);
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
        s.spawn(|| {
            println!("Data: {:?}", data);
        });
    });
}
```

#qa[Why can scoped threads borrow data?][The scope blocks until all threads finish, so the compiler knows `data` outlives the threads.]

== Moving to threads

You can also send input to spawned threads.

- using a channel sender (see next section)
- using the `move` keyword to transfer ownership at spawn time

Since spawn time means *at runtime*, non-`'static` references cannot be moved to threads.

```rs
fn spawn<F, T>(f: F) -> JoinHandle<T>
where
    F: FnOnce() -> T + Send + 'static,
    T: Send + 'static
```

#pause

#codly(
  annotations: (
    (start: 3, end: 5, content: [closure `f` must be `'static`]),
  ),
)
```rs
fn main() {
    let data = String::from("hello");
    let handle = thread::spawn(move || {
        println!("Data: {data}"); // `data` moved into closure, now owned by thread
    });
    // println!("{data}"); // Error: value moved
    handle.join().unwrap();
}
```

#qa[Why does `thread::spawn` require `'static`?][The spawned thread may outlive the caller. Without `'static`, the closure could hold dangling references.]



= Channels

== Senders and Receivers

#qa[What does `mpsc` stand for?][Multiple Producer, Single Consumer.]


```rs
fn main() {
    let (tx, rx) = std::sync::mpsc::channel();

    tx.send(10).unwrap();
    tx.send(20).unwrap();

    println!("Received: {:?}", rx.recv());
    println!("Received: {:?}", rx.recv());

    let tx2 = tx.clone();
    tx2.send(30).unwrap();
    println!("Received: {:?}", rx.recv());
}
```

#qa[What happens when you call send and all receivers have been dropped?][`send()` returns an error (channel is "closed").]




== Unbounded Channels

#qa[What happens when you call send and no receivers are listening?][Message is queued until a receiver is available.]



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

== Bounded channels

```rs
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

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

== Exercises

- examples/threads3.rs

= Send and Sync
== Marker Traits

How does Rust know to forbid shared access across threads?

#pause


- `Send`: a type T is Send if it is safe to move a T across a thread boundary. #pause
- `Sync`: a type T is Sync if it is safe to move a &T across a thread boundary.

#pause

#info[Send and Sync are unsafe auto traits.]

#qa[What are auto traits?][The compiler will automatically derive them for your types as long as they only contain types that implement the auto trait.]

#qa[What are `unsafe` traits?][Traits that have safety invariants that the compiler cannot verify automatically. Implementing them incorrectly can lead to undefined behavior.]

You can implement `unsafe` traits manually when you know it is valid.

#pause

#warning[Implementing `unsafe` traits requires `unsafe` blocks. Using them as constraints does not.]

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

#qa[The `lock()` returns a `Result<MutexGuard<T>, PoisonError>`. What is a `PoisonError`? ][It indicates that another thread panicked while holding the lock, potentially leaving the data in an inconsistent state.]

#pagebreak()

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

Open `examples/demo.rs`

#pause


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
- Use at most one `Arc<Mutex<T>>` per program.
- Use `RwLock<T>` when possible.
- Use `Atomic` types for simple shared counters/flags.



= Exercises


From Google:

- examples/philosophers.rs
- examples/link.rs
