
#import "../template.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 3: Ownership],
    subtitle: [Memory model, ownership],
    author: [Willem Vanhulle],
    date: [Tuesday November 18, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#title-slide()

#focus-slide[
  #image("images/ownership.png")
]

= Review


#focus-slide[
  #image("images/chinese.jpg")
]

== Installation



Install and run Rustlings:

- `cargo install rustlings`
- `rustlings init` (creates new directory in the current directory)
- `cd rustlings/`
- open the `rustlings` folder in your IDE
- run `rustlings` in a background terminal
- follow the instructions in the terminal

(See https://rustlings.rust-lang.org/setup/ for more.)




== Exercises

#slide[
  #set text(size: 0.8em)

  === Rustling exercises

  Review first session:

  - Ex 2. Functions
  - Ex 4. Primitive types
  - Ex 7. Structs
  - Ex 8. Enums

  Review last session:

  - Ex 12. Option
  - Ex 15. Traits
  - Ex 5. Vectors
  - Ex 9. Strings

  If you have time:

  - Ex 14. Generics
  - Ex 11. HashMaps
  - Ex 6. Move semantics

][

  === Google exercises


  - `session-3/examples/s2d6-closures.rs`
  - `session-3/examples/s2d8-counter.rs`



][
  === Additional exercises

  - `session-3/examples/s3e2-trait-conflicts.rs`
  - `session-3/examples/s3e3-basic-traits.rs`
  - `session-3/examples/s2d5-fn-trait.rs`
  - `session-3/examples/s2d6-fnmut-trait.rs`
  - `session-3/examples/s3e4-supertraits.rs`
  - `session-3/examples/s3e5-multiple-bounds.rs`
  - `session-3/examples/s3e6-dispatch.rs`

]

#include "1-std-traits.typ"
#include "2-ownership.typ"

