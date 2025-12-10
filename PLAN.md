# Course plan

## Session 1

[Slides](./session-1/slides.pdf)

**Covered in class:**

- Welcome: *5 min*
- Hello, world: *15 min*
- Types and values: *40 min*
- Control flow basics: *45 min*
- Tuples and arrays: *35 min*
- References: *55 min* (partially)

**Not covered in session 1:**

- User-defined types: *60 min*
- Pattern matching: *50 min*

**Homework:**

- User defined types
  - [Structs](https://doc.rust-lang.org/book/ch05-00-structs.html)
  - [Enums](https://doc.rust-lang.org/book/ch06-00-enums.html)
- Pattern matching (if needed)
  - [Enums and Pattern Matching](https://doc.rust-lang.org/book/ch06-00-enums.html)
  - [Advanced Patterns](https://doc.rust-lang.org/book/ch19-00-patterns.html)

---

## Session 2

[Slides](./session-2/slides.pdf)

**Covered in class:**

- Methods and traits: *45 min*
  - [Traits](https://doc.rust-lang.org/book/ch10-02-traits.html)
- Generics: *50 min*
  - [Generic Types, Traits, and Lifetimes](https://doc.rust-lang.org/book/ch10-01-syntax.html)
  - [Advanced Traits](https://doc.rust-lang.org/book/ch20-02-advanced-traits.html)
- Closures: *30 min* (see homework)
- Standard library types: *15 min* (partially)

**Not covered in session 2** *(see homework)*:

- Standard library types: *15 min* (partially)
- Standard library traits: *60 min*

**Homework:**

- Review closures:
  - [How Functions Work](https://doc.rust-lang.org/book/ch03-03-how-functions-work.html)
  - [Closures: Anonymous Functions that Capture Their Environment](https://doc.rust-lang.org/book/ch13-01-closures.html)
  - [Advanced Functions and Closures](https://doc.rust-lang.org/book/ch20-04-advanced-functions-and-closures.html)
- Standard library types
  - [Common Collections](https://doc.rust-lang.org/book/ch08-00-common-collections.html)
  - [Advanced Types](https://doc.rust-lang.org/book/ch20-03-advanced-types.html)
- Standard library traits
  - [Functional Language Features: Iterators and Closures](https://doc.rust-lang.org/book/ch13-00-functional-features.html)
- Read the chapter about ownership to prepare for session 3:
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)
  - [Smart Pointers](https://doc.rust-lang.org/book/ch15-00-smart-pointers.html)

---

## Session 3

[Slides](./session-3/slides.pdf)

**Planned for in-session:**

- Mid-series exercise session (see subfolder `examples`): *60 min.*
  - Replace `todo!` macro calls by real code
  - Use `cargo run --example` to test your solutions
- Standard library traits: 15 min. (depending on students)
  - <https://doc.rust-lang.org/book/appendix-03-derivable-traits.html>
- Memory Management: *30 min*
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)

**Homework:**

- Review the chapter about ownership:
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)
  - [Smart Pointers](https://doc.rust-lang.org/book/ch15-00-smart-pointers.html)
- Borrowing: *45 min*
- Prepare lifetimes for next session: *65 min*

---

## Session 4

[Slides](./session-4/slides.pdf)

**Planned for in-session:**

- Smart-pointers recap: 15 min. exercises
- Lifetimes: *60 min* theory and exercises
- Iterators: *45 min* theory

**Homework:**

- Lifetimes:
  - Read <https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html>
  - Read <https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html>
  - Exercise session-4/tests/protobuf-parsing.rs
  - Exercises Rustlings, ch. 16 lifetimes
- Iterators:
  - Exercise session-4/tests/iterator-method-chaining.rs
  - <https://doc.rust-lang.org/book/ch13-00-functional-features.html>
  - Exercise Rustlings, ch. 18 iterators
  - Extra exercise: make your own iterator and adapter
- Modules: *45 min*
  - Read <https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html>
  - Read <https://doc.rust-lang.org/book/appendix-04-useful-development-tools.html>
  - Exercise: Rustlings, ch. 10 modules
- Testing: *45 min*
  - Read <https://doc.rust-lang.org/book/ch11-00-testing.html>
  - Exercise: Rustlings, ch. 17 tests

---

## Session 5

[slides](./session-5/slides.pdf)

**Planned for in-session:**

- Review testing and modules: *30 min*
  - session-5/tests/luhn.rs
- Error handling: *55 min*
  - Rustlings, chapter 13: Error handling
  - session-5/tests/result.rs
- Unsafe rust: *20 min*

**Homework:**

- Review error handling:
  - Read <https://doc.rust-lang.org/book/ch09-00-error-handling.html>
- Unsafe Rust: *30 min*
  - Read <https://google.github.io/comprehensive-rust/bare-metal/>

---

## Session 6

([Slides](./session-6/slides.pdf))

**Planned for in-session:**

- Threads: *30 min*
- Channels: *20 min*
- Send and Sync: *15 min*
- Shared state: *30 min*

**Homework:**

- Project work (find a partner)
- Exercises concurrency: *70 min*

---

## Session 7

**Planned for in-session:**

- Async basics: *40 min*
- Channels and control flow: *20 min*
- Project presentation: *60 min*

**Homework:**

- Blocking the Executor: *10 min*
- Pin: 20 min
- Async traits: 5 min
- Cancellation: 20 min
- Exercises: *70 min*
