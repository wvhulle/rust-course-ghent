# Contributing

## Source material

For this course, I combined material from Google's "Comprehensive Rust", "Rustlings" and the "Programming Rust" book by Jim Blandy.

## Slides

To compile the slides of a single session (install Typst first):

```bash
cd sessions
typst compile --root . session1/slides.typ
xdg-open session1/slides.pdf
```

The slides are written in [Typst](https://typst.app/). There is a [`template/lib.typ`](./template/lib.typ) and accompanying custom layout functions in the [`template`](./template/) folder. Please refer to the manual of each Typst package for external packages:

- Touying (for slides): <https://touying-typ.github.io/>
- Tiaoma (for QR-codes): typst.app/universe/package/tiaoma/
- Fletcher (for node-based diagrams): <https://typst.app/universe/package/fletcher>

If you don't want the slides to be cut into subslides with partial reveals, you can compile a PDF for handouts by adjusting the [`Touying`](https://typst.app/universe/package/touying/) configuration in the source code.

```typ
config-common(handout: true)
```

## Exercises

Students have read the relevant chapters from the Rust Book and have programming experience in other languages. Students should be **guided into making errors first**, then discover the correct solution through compiler feedback.
