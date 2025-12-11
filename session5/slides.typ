
#import "../template/lib.typ": *

#import "@preview/cetz:0.4.2"



#show: rust-course.with(
  config-info(
    title: [Lecture 5: Error handling],
    subtitle: [Review tests, learn error handling, unsafe Rust],
    author: [Willem Vanhulle],
    date: [Tuesday December 2, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#let events = [
  == Events coming up

  Scripting with Nu Shell:

  - Target audience: DevOps, sysadmins, backend developers
  - Date: *tomorrow*, Wednesday December 3, 2025
  - Time: 19:00 - 20:00
  - Location: Kammerstraat 10, 9000 Gent
  - Registration: https://www.meetup.com/sysghent/events/311799711

  ```bash
  ps | where name == Notepad2.exe | get pid.0 | kill $in
  ```

  #pause

  WebAssembly for secure systems and services:

  - Target audience: web developers, full-stack developers, systems programmers, cloud developers
  - Date: Tuesday December 16, 2025
  - Time: 19:00 - 20:00
  - Location: DoubleVerify near Flanders Expo
  - Registration: https://www.meetup.com/sysghent/events/312172422

  Events TBA: performance and benchmarking, technical writing with Typst
]

#let tools = [
  == New tools

  Forked `rustowl` as `ferrous-owl` to support Helix and NixOS and add tests (*testers needed*):

  - Crates.io: https://crates.io/crates/ferrous-owl
  - VS Code: https://marketplace.visualstudio.com/items?itemName=WillemVanhulle.ferrous-owl

  #image("images/rustowl.png", height: 18em)
]

#title-slide()

= Review tests

Allocated time: 15 min



#events


#tools

= Error handling

Allocated time: 55 min

== Panics

In case of a fatal runtime error, Rust triggers a “panic”:

```rust
fn main() {
    let v = vec![10, 20, 30];
    dbg!(v[100]);
}
```

#warning[Panics are for unrecoverable and unexpected errors.]

#pause



#pagebreak()

#focus-slide[
  #box[
    #image("images/bomb.jpg", width: 20cm)

    #pause

    #place(center + horizon, dx: -4cm, dy: -1cm)[
      #text(fill: green, size: 1.5em, weight: "bold")[write  `panic!()`]
    ]

    #pause

    #place(center + horizon, dx: 4cm, dy: 1cm)[
      #text(fill: red, size: 1.5em, weight: "bold")[Boom]
    ]

    #pause

    #place(center + horizon, dx: -4cm, dy: 1cm)[
      #text(fill: blue, size: 1.5em, weight: "bold")[Panic! ]
    ]
  ]
]

== Panics in both debug and release mode

#slide[
  #qa[Name a panic cause related to indexing.][
    Out-of-bounds array/vector indexing
  ]

  #qa[Name a panic cause related to arithmetic.][
    Division by zero
  ]

  #qa[Name 2 panic causes related to Option/Result handling.][
    1. Calling `unwrap()` on `None`
    2. Calling `unwrap()` or `expect()` on `Err`
  ]

][

  #qa[Name 3 panic causes related to explicit panic macros.][
    1. Explicit `panic!()` macro invocation
    2. `unreachable!()` macro reached
    3. `todo!()` or `unimplemented!()` macro reached
  ]

  #qa[Name a panic cause related to assertions.][
    `assert!()` or `assert_eq!()` failure
  ]

  #qa[Name a panic cause related to runtime limits.][
    Stack overflow from infinite recursion
  ]]


#focus-slide[
  #box[
    #image("images/reality.jpg")
    #place(center + horizon, dx: 5cm, dy: 0cm)[
      #text(size: 1.5em, weight: "bold")[Bye-bye \ debug mode]
    ]
  ]

]

== Panics silent in release


#slide[


  #qa[Why does debug mode have more panics?][Debug mode prioritizes catching bugs early with runtime checks.  ]

  #qa[Why does release mode have fewer panics?][Release mode removes some runtime checks to optimize speed.]

  #qa[Name 3 debug-only panics related to arithmetic.][
    1. Integer overflow (wraps silently in release)
    2. Integer underflow (wraps silently in release)
    3. Multiplication overflow (e.g., large `i32 * i32`)
  ]

][
  #pause
  #warning[
    In release mode, integer overflow wraps around (e.g., `u8::MAX + 1 == 0`).
    Use `wrapping_*`, `checked_*`, `saturating_*`, or `overflowing_*` methods for explicit control.
  ]

  #qa[Name 3 debug-only panics related to debug assertions.][
    1. `debug_assert!()` failure (ignored in release)
    2. `debug_assert_eq!()` failure (ignored in release)
    3. `debug_assert_ne!()` failure (ignored in release)
  ]
]







== Catching panics

This can be useful in servers which should keep running even if a single request crashes.

```rs
use std::panic;

fn main() {
    let result = panic::catch_unwind(|| "No problem here!");
    dbg!(result);

    let result = panic::catch_unwind(|| {
        panic!("oh no!");
    });
    dbg!(result);
}
```

This does not work if panic = 'abort' is set in your Cargo.toml.

#info[While `unwind`-ing the stack, destructors are still run for all in-scope variables.]


== Result

```rs
use std::fs::File; use std::io::Read;
fn main() {
    let file: Result<File, std::io::Error> = File::open("diary.txt");
    match file {
        Ok(mut file) => {
            let mut contents = String::new();
            if let Ok(bytes) = file.read_to_string(&mut contents) {
                println!("Dear diary: {contents} ({bytes} bytes)");
            } else {
                println!("Could not read file content");
            }
        }
        Err(err) => {
            println!("The diary could not be opened: {err}");
        }
    }
}
```


== Exceptions

Example of implicit exception in C++:

```cpp
void read_file() {
    std::ifstream file("diary.txt");
    if (!file) throw std::runtime_error("Cannot open file");
    // Caller has no indication this function can throw
}

int main() { read_file(); }
```

#qa[What are exceptions in other languages the closest to? Abort panics, unwind panics, or results?][Results]

#qa[What is the difference between a rust `Result` and exceptions in other languages?][Results must be handled with pattern matching, while exceptions are often implicit.]


#focus-slide[
  #box[
    #image("images/normal.png", width: 20cm)

    #pause
    #place(center + horizon, dy: 0cm)[
      #text(fill: blue, size: 1.5em, weight: "bold")[`Ok()`]
    ]
    #pause
    #place(center + horizon, dx: 6cm, dy: 3cm)[
      #text(fill: red, stroke: white, size: 1.5em, weight: "bold")[`Err()`]


    ]
    #pause

    #place(center + horizon, dx: 14cm)[
      #text(weight: "bold")[ `Err()`ors \ are a \ fact of life]
    ]
  ]

]

== Exercises

Rustlings, chapter 13 (`error_handling`): ex. 1, 2, 4, 6


== To `unwrap` or not to `unwrap`

The `Result` type has a convenience method:

```rs
let file = File::open("diary.txt").unwrap();
```

#qa[When is it appropriate to use `unwrap()`?][When you are sure the `Result` is `Ok`, such as in tests or examples.]

#qa[When should never use `unwrap()`?][In production code where the `Result` could be `Err`, as it can cause panics.]

But what if we add a reason like this?

```rs
let file = File::open("diary.txt").expect("Diary must exist");
```

#qa[Why is this a bad idea?][You are essential writing a string comment that refers to an anonymous variable. ]

== Implementing your own Error types

Instead using `panic!()` or `expect()`, define your own error types.

```rs
#[derive(Debug)]
enum MathError {
    DivisionByZero,
    NegativeLogarithm,
}

impl Error for MathError {}
```

Whenever you unwrap a `Result::Err<_, MathError>` and get a panic, the Rust binary prints the `MathError` value:

```
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: DivisionByZero', src/main.rs:10:34
```

#warning[Add error metadata to the error enum variants!]

== Exercise

Complete example `examples/custom-error.rs`.



== `Try` operator

Matching on `Result` on every call can be cumbersome.

#pause

You can rewrite:

```rs
match some_expression {
    Ok(value) => value,
    Err(err) => return Err(err),
}
```

Into: #pause `some_expression?`.

#focus-slide[
  #image("images/short-circuit.webp", width: 100%)
]


== Exercise

Rustlings:

- Ch 13, ex.3, 5

Google:

- Rewrite `examples/short-circuit.rs` to use the `?` operator.
- Fix `tests/error-handling.rs`.

== `main` returning `Result`

```rs
fn main() -> Result<(), Error> {}
```

#qa[Should you annotate the return type of `main` to be `Result<(), E>`?][No, because most `E` implement `Debug`.]

The executable will print the Err variant and return a nonzero exit status on error.

#pause

How does this work?

#pause

```rs
impl Termination for Infallible {}
impl Termination for ! {}
impl Termination for () {}
impl Termination for ExitCode {}
impl<T: Termination, E: Debug> Termination for Result<T, E> {}
```

== Dynamic Error Types (bad idea)

```rs
use std::error::Error; use std::fs; use std::io::Read;
fn read_count(path: &str) -> Result<i32, Box<dyn Error>> {
    let mut count_str = String::new();
    fs::File::open(path)?.read_to_string(&mut count_str)?;
    let count: i32 = count_str.parse()?;
    Ok(count)
}

fn main() {
    fs::write("count.dat", "1i3").unwrap();
    match read_count("count.dat") {
        Ok(count) => println!("Count: {count}"),
        Err(err) => println!("Error: {err}"),
    }
}
```

#focus-slide[
  #image("images/ariadne.png")
]

= Unsafe Rust

Allocated time: 30 min

== `Unsafe`

Unsafe Rust gives you access to five new capabilities:


- Dereference raw pointers.
- Access or modify mutable static variables.
- Access union fields.
- Call unsafe functions, including extern functions.
- Implement unsafe traits.


Unsafe code is usually small and isolated, and its correctness should be carefully documented. It is usually wrapped in a safe abstraction layer.

#qa[What is undefined behaviour (UB) in Rust?][
  When the compiler assumes certain invariants hold, but they are violated at runtime, leading to unpredictable behavior.
]

#qa[What is the relationship between unsafe code and undefined behaviour?][
  Unsafe code likely leads to undefined behavior.
]

#focus-slide[
  #image("images/stroustrup.jpg")
]

== Safety comments

```rs
fn main() {
    let mut x = 10;

    let p1: *mut i32 = &raw mut x;
    let p2 = p1 as *const i32;

    // SAFETY: p1 and p2 were created by taking raw pointers to a local, so they
    // are guaranteed to be non-null, aligned, and point into a single (stack-)
    // allocated object.
    unsafe {
        dbg!(*p1);
        *p1 = 6;
        // Mutation may soundly be observed through a raw pointer, like in C.
        dbg!(*p2);
    }

}
```

== Incorrect unsafe code

```rs
fn main() {
    let mut x = 10;

    let p1: *mut i32 = &raw mut x;
    let p2 = p1 as *const i32;

    // UNSOUND. DO NOT DO THIS.
    /*
    let r: &i32 = unsafe { &*p1 };
    dbg!(r);
    x = 50;
    dbg!(r); // Object underlying the reference has been mutated. This is UB.
    */
}
```

== Exercise: Unsafe Pointer Dereferencing

Complete `examples/unsafe-pointers.rs`

Run tests: `cargo test --example unsafe-pointers`

== Mutable Static Variables

It is safe to read an immutable static variable:

```rs
static HELLO_WORLD: &str = "Hello, world!";

fn main() {
    println!("HELLO_WORLD: {HELLO_WORLD}");
}
```

== Unsafe mutation of static variables
Using mutable statics soundly requires reasoning about concurrency without the compiler’s help:

```rs
static mut COUNTER: u32 = 0;
fn add_to_counter(inc: u32) {
    // SAFETY: There are no other threads which could be accessing `COUNTER`.
    unsafe {
        COUNTER += inc;
    }
}
fn main() {
    add_to_counter(42);
    // SAFETY: There are no other threads which could be accessing `COUNTER`.
    unsafe {
        dbg!(COUNTER);
    }
}
```
May cause race-conditions if multiple threads access the static simultaneously.

#focus-slide[
  #image("images/pico.jpg", width: 100%)
]

== Unsafe in `no_std` environments

#qa[What does `no_std` mean?][
  A Rust environment without the standard library and optional heap allocator.
]

Remember: `std` > `alloc` > `core`


== Unsafe in embedded

```rs
#![no_std]
// Raw pointer to memory-mapped I/O register
static GPIO_OUTPUT: *mut u32 = 0x4000_5000 as *mut u32;

fn set_pin_high(pin: u8) {
    // SAFETY: GPIO_OUTPUT points to a valid memory-mapped register
    // and we have exclusive access during startup.
    unsafe {
        GPIO_OUTPUT.write_volatile(1 << pin);
    }
}
```

#info[A lot of `unsafe` in embedded code is abstracted away in Hardware Abstraction Layer (HAL) crates.]

#pagebreak()

#qa[Do raw pointers replace references in `no_std` code?][
  No. Higher-level `no_std` code still uses references normally. Raw pointers are only necessary when interfacing with hardware or memory regions where the compiler cannot verify validity.
]

#qa[Which validity guarantees do references require that can't be verified for hardware addresses?][
  References must be non-null, properly aligned, and point to initialized memory. For hardware addresses, the compiler cannot verify these properties, so raw pointers are used instead.
]

== Exercise


Try to flash a simple blink program using the HAL crate one of the supported boards.

#warning[Only use the processor or HAL crate for the exercises, no high-level frameworks like Embassy!]

Ask for boards and help if needed.

See also my SysGhent workshop for building a smart plant pot with embedded Rust: https://github.com/sysghent/plant-pot

=== Raspberry Pi Pico

For example, you could flash a Raspberry Pi Pico with https://github.com/rp-rs/rp-hal.

You can find example programs on https://github.com/rp-rs/rp-hal/tree/main/rp2040-hal-examples/src/bin

=== ESP32

Have a look at https://github.com/esp-rs/esp-hal




== Unions

Unions are like enums, but you need to track the active field yourself:

```rs
#[repr(C)]
union MyUnion {
    i: u8,
    b: bool,
}

fn main() {
    let u = MyUnion { i: 42 };
    println!("int: {}", unsafe { u.i });
    println!("bool: {}", unsafe { u.b }); // Undefined behavior!
}
```

#pause

Occasionally needed for interacting with C library APIs.

#pause

If you just want to reinterpret bytes as a different type, you probably want `std::mem::transmute`.


= Homework

#events

== Homework

=== Projects

*Final reminder for student projects*:

- Only Rust code, no markdown files
- *No AI*
- *Deadline: this Thursday, Dec. 4*

Please open a PR and add me as reviewer. My e-mail is #link("willemvanhulle@protonmail.com") and GitHub ID is "wvhulle"

#pause

=== Reading

Review:

- Error handling: https://doc.rust-lang.org/book/ch09-00-error-handling.html
- Unsafe Rust:
  - Very good read:  last chapter in "Programming Rust" by Blandy
  - Unfinished chapters in https://google.github.io/comprehensive-rust/bare-metal/


Prepare for next session about parallel programming, *it will be mind-blowing*!

