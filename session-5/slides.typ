
#import "../template.typ": *

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
  - Date: tomorrow, Wednesday December 3, 2025
  - Time: 19:00 - 20:00
  - Location: Kammerstraat 10, 9000 Gent
  - Registration: https://www.meetup.com/sysghent/events/311799711

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



#pagebreak()

== Panics only in debug mode (silent in release)


#slide[


  #qa[Why does debug mode have more panices?][Debug mode prioritizes catching bugs early with runtime checks.  ]

  #qa[Why does release mode have fewer panics?][Release mode removes some runtime checks to optimize speed.]

  #qa[Name 3 debug-only panics related to arithmetic overflow/underflow.][
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
      #text(fill: red, size: 1.5em, weight: "bold")[`Err()`]
    ]
  ]

]

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

#pause

*Exercise*:

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

= Unsafe Rust

Allocated time: 30 min

== `Unsafe`

The Rust language has two parts:

- Safe Rust: memory safe, no undefined behavior possible.
- Unsafe Rust: can trigger undefined behavior if preconditions are violated.


Unsafe Rust gives you access to five new capabilities:

- Dereference raw pointers.
- Access or modify mutable static variables.
- Access union fields.
- Call unsafe functions, including extern functions.
- Implement unsafe traits.




Unsafe code is usually small and isolated, and its correctness should be carefully documented. It is usually wrapped in a safe abstraction layer.


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

== Unsafe in `no_std` environments


```rs
#![no_std]
#![no_main]
// Raw pointer to memory-mapped I/O register
static GPIO_OUTPUT: *mut u32 = 0x4000_5000 as *mut u32;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    // SAFETY: GPIO_OUTPUT points to a valid memory-mapped register
    // and we have exclusive access during startup.
    unsafe {
        GPIO_OUTPUT.write_volatile(1 << 5);  // Set pin 5 high
    }
    loop {}
}
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! { loop {} }
```

#pagebreak()

#qa[Do raw pointers replace references in `no_std` code?][
  No. Higher-level `no_std` code still uses references normally. Raw pointers are only necessary when interfacing with hardware or memory regions where the compiler cannot verify validity.
]

#qa[Which validity guarantees do references require that can't be verified for hardware addresses?][
  References must be non-null, properly aligned, and point to initialized memory. For hardware addresses like memory-mapped I/O registers, the compiler cannot verify these properties, so raw pointers are used instead.
]

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



*Final reminder for student projects*:

- Only Rust code, no markdown files
- *No AI*-generated code or text
- No AI-assistance during writing
- Open a PR and add me as reviewer
- *Deadline: this Thursday, Dec. 4*

My e-mail is #link("willemvanhulle@protonmail.com") and GitHub ID is "wvhulle"

#pause

Review:

- error handling:  https://doc.rust-lang.org/book/ch09-00-error-handling.html
- Unsafe Rust:  https://google.github.io/comprehensive-rust/bare-metal/
