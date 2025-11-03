# DevLab Rust 2025

Evening lectures on Rust in Ghent Nov - Dec 2025 for experienced developers. Registration is possible [on pretix.eu](https://pretix.eu/devlab/rust-course/).

## Course plan

1. **Introduction** — Patterns, methods, traits and generics ([slides](./session-1/slides.pdf))
2. **Functional Programming & Standard Library** — Closures, stdlib types, traits
3. **Ownership & Borrowing Fundamentals** — Borrowing, lifetimes, error handling
4. **Advanced Memory Management** — Memory management, smart pointers
5. **Code Organization & Quality** — Iterators, modules, testing
6. **Concurrency & Error Handling** — Threads, channels, Send/Sync, shared state
7. **Asynchronous Programming** (Bonus) — Async basics, channels, Pin, cancellation

## Lecture material

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
