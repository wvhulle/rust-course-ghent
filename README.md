# DevLab Rust 2025

Evening lectures on Rust in Ghent Nov - Dec 2025 for experienced developers. Registration is possible [on pretix.eu](https://pretix.eu/devlab/rust-course/).

## Guidelines

The day after each session I will send an e-mail with the chapters we covered and what you can do to prepare for the next session.

Please **spend at least 60 min. a week at home reading the chapters** mentioned in the e-mail in the [freely available official Rust book](https://doc.rust-lang.org) or making exercises.

For the in-person sessions:

- Take a **laptop** to solve exercises during the session.
- Do not spend time cloning, pulling or installing during the session.
- Download the PDF of the slides which contain links to the playground. Click the links during the session if needed.
- Turn of your AI editor extensions (you can do it for Rust only).

## Session 1

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

**Covered in class:**

- Methods and traits: *45 min*
  - [Traits](https://doc.rust-lang.org/book/ch10-02-traits.html)
- Generics: *50 min*
  - [Generic Types, Traits, and Lifetimes](https://doc.rust-lang.org/book/ch10-01-syntax.html)
  - [Advanced Traits](https://doc.rust-lang.org/book/ch20-02-advanced-traits.html)
- Closures: *30 min* (see homework)

**Not covered in session 2** *(see homework)*:

- Standard library types: *60 min*
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

**Planned for in-session:**

- Memory Management: *60 min*
  - [Understanding Ownership](https://doc.rust-lang.org/book/ch04-00-understanding-ownership.html)

- Smart pointers: *55 min*
  - [Smart Pointers](https://doc.rust-lang.org/book/ch15-00-smart-pointers.html)

**Homework:**

- Borrowing: *45 min*
- Prepare lifetimes for next session: *65 min*

---

## Session 4

**Planned for in-session:**

- Lifetimes: *65 min*
- Iterators: *55 min*

**Homework:**

- Testing: *45 min*
- Modules: *45 min*

---

## Session 5

**Planned for in-session:**

- Error handling: *55 min*
- Threads: *30 min*
- Channels: *20 min*

**Homework:**

- Unsafe rust: *75 min*

---

## Session 6

**Planned for in-session:**

- Send and Sync: *15 min*
- Shared state: *30 min*
- Project work (find a partner): *65 min*

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

## Lecture material

### Exercises

Install Rust as explained in [rustup.rs/](https://rustup.rs/). (For Windows users: don't use `winget` or `chocolatey`)

Exercise statements for session X can be found in the `examples` or `tests` folder of session X. The name of the exercise file you need will be referenced at the end of each chapter in the slides.

Test your solution to a particular exercise (from any subdirectory) with a command like this (for session 1, exercise 1):

```bash
cargo run --example s1e1-fibonacci # For binary examples
cargo run --test s1e1-fibonacci # For test examples
```

(Please **avoid searching for existing solutions** or using AI unless you tried at least a few times.)

### Project

You will have select a topic to work on and finish a larger task (in group or alone). Add your ideas to [./projects.md](./projects.md).

### Theory

For this course, I combined material from Google's "Comprehensive Rust" and the "Programming Rust" book by Jim Blandy.

To compile the slides of a single session (install Typst first):

```bash
cd sessions
typst compile --root . session-1/slides.typ
xdg-open session-1/slides.pdf
```

If you don't want the slides to be cut into subslides with partial reveals, you can compile a PDF for handouts by adjusting the [`Touying`](https://typst.app/universe/package/touying/) configuration in the source code.

```typ
config-common(handout: true)
```

## Contributing

The slides are written in [Typst](https://typst.app/). There is a [`template.typ`](./template.typ) and a few accompanying custom layout functions in the [`theme`](./theme/) folder.

Please refer to the manual of each package for external packages.

- Touying (for slides): <https://touying-typ.github.io/>
- Tiaoma (for QR-codes): typst.app/universe/package/tiaoma/
- Fletcher (for node-based diagrams): <https://typst.app/universe/package/fletcher>
