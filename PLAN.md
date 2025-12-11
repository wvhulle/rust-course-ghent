# Course plan

## Session 1

[Slides](./session1/slides.pdf)

**Covered in class:**

- Welcome: _5 min_
- Hello, world: _15 min_
- Types and values: _40 min_
- Control flow basics: _45 min_
- Tuples and arrays: _35 min_
- References: _55 min_ (partially)

**Not covered in session 1:**

- User-defined types: _60 min_
- Pattern matching: _50 min_

**Homework:**

- User defined types
  - [Structs](https://doc.rust-lang.org/book/ch05-00-structs.html)
  - [Enums](https://doc.rust-lang.org/book/ch06-00-enums.html)
- Pattern matching (if needed)
  - [Enums and Pattern Matching](https://doc.rust-lang.org/book/ch06-00-enums.html)
  - [Advanced Patterns](https://doc.rust-lang.org/book/ch19-00-patterns.html)

---

## Session 2

[Slides](./session2/slides.pdf)

**Covered in class:**

- Methods and traits: _45 min_
  - [Traits](https://doc.rust-lang.org/book/ch10-02-traits.html)
- Generics: _50 min_
  - [Generic Types, Traits, and Lifetimes](https://doc.rust-lang.org/book/ch10-01-syntax.html)
  - [Advanced Traits](https://doc.rust-lang.org/book/ch20-02-advanced-traits.html)
- Closures: _30 min_ (see homework)
- Standard library types: _15 min_ (partially)

**Not covered in session 2** _(see homework)_:

- Standard library types: _15 min_ (partially)
- Standard library traits: _60 min_

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

[Slides](./session3/slides.pdf)

**Planned for in-session:**

- Mid-series exercise session (see subfolder `examples`): _60 min._
  - Replace `todo!` macro calls by real code
  - Use `cargo run --example` to test your solutions
- Standard library traits: 15 min. (depending on students)
  - <https://doc.rust-lang.org/book/appendix-03-derivable-traits.html>
- Memory Management: _30 min_
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)

**Homework:**

- Review the chapter about ownership:
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)
  - [Smart Pointers](https://doc.rust-lang.org/book/ch15-00-smart-pointers.html)
- Borrowing: _45 min_
- Prepare lifetimes for next session: _65 min_

---

## Session 4

[Slides](./session4/slides.pdf)

**Planned for in-session:**

- Smart-pointers recap: 15 min. exercises
- Lifetimes: _60 min_ theory and exercises
- Iterators: _45 min_ theory

**Homework:**

- Lifetimes:
  - Read <https://doc.rust-lang.org/book/ch04-02-references-and-borrowing.html>
  - Read <https://doc.rust-lang.org/book/ch10-03-lifetime-syntax.html>
  - Exercise session4/tests/protobuf-parsing.rs
  - Exercises Rustlings, ch. 16 lifetimes
- Iterators:
  - Exercise session4/tests/iterator-method-chaining.rs
  - <https://doc.rust-lang.org/book/ch13-00-functional-features.html>
  - Exercise Rustlings, ch. 18 iterators
  - Extra exercise: make your own iterator and adapter
- Modules: _45 min_
  - Read <https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html>
  - Read <https://doc.rust-lang.org/book/appendix-04-useful-development-tools.html>
  - Exercise: Rustlings, ch. 10 modules
- Testing: _45 min_
  - Read <https://doc.rust-lang.org/book/ch11-00-testing.html>
  - Exercise: Rustlings, ch. 17 tests

---

## Session 5

[slides](./session5/slides.pdf)

**Planned for in-session:**

- Review testing and modules: _30 min_
  - session5/tests/luhn.rs
- Error handling: _55 min_
  - Rustlings, chapter 13: Error handling
  - session5/tests/result.rs
- Unsafe rust: _20 min_

**Homework:**

- Review error handling:
  - Read <https://doc.rust-lang.org/book/ch09-00-error-handling.html>
- Unsafe Rust: _30 min_
  - Read <https://google.github.io/comprehensive-rust/bare-metal/>

---

## Session 6

([Slides](./session6/slides.pdf))

**Planned for in-session:**

- Threads: _30 min_
- Channels: _20 min_
- Send and Sync: _15 min_
- Shared state: _30 min_

**Homework:**

- Project work (find a partner)
- Exercises concurrency: _70 min_

---

## Session 7

**Planned for in-session:**

- Async basics: _40 min_
- Channels and control flow: _20 min_
- Project presentation: _60 min_

**Homework:**

- Blocking the Executor: _10 min_
- Pin: 20 min
- Async traits: 5 min
- Cancellation: 20 min
- Exercises: _70 min_
