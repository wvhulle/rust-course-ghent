# DevLab Rust 2025

Evening lectures on Rust in Ghent Nov - Dec 2025 for experienced developers. Registration is possible [on pretix.eu](https://pretix.eu/devlab/rust-course/).

## Before each session

Important:

- Take a **laptop** to solve exercises during the session.
- **Install Rust**, clone this repo.
- Review topics covered in previous sessions.

If possible:

- Turn of your AI editor extensions (you can do it for Rust only).
- Download the PDF of the slides (as back-up).

## Course plan

1. **Introduction** — Patterns, methods, traits and generics ([slides](./session-1/slides.pdf))
2. **Functional Programming & Standard Library** — Closures, stdlib types, traits
3. **Ownership & Borrowing Fundamentals** — Borrowing, lifetimes, error handling
4. **Advanced Memory Management** — Memory management, smart pointers
5. **Code Organization & Quality** — Iterators, modules, testing
6. **Concurrency & Error Handling** — Threads, channels, Send/Sync, shared state
7. **Asynchronous Programming** (Bonus) — Async basics, channels, Pin, cancellation

## Lecture material

### Exercises

Exercise statements for session X can be found in the `examples` or `tests` folder of session X. The name of the exercise file you need will be referenced at the end of each chapter in the slides.

Test your solution to a particular exercise (from any subdirectory) with a command like this (for session 1, exercise 1):

```bash
cargo run --example s1e1-fibonacci
```

(Please **avoid searching for existing solutions** or using AI unless you tried at least a few times.)

### Project

You will have select a topic to work on and finish a larger task (in group or alone). Projects. Open a PR to [./projects.md](./projects.md) to list your project.

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
