
#import "../template.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 3: Ownership],
    subtitle: [Mid-series exercises and move semantics],
    author: [Willem Vanhulle],
    date: [Tuesday November 18, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#title-slide()

= Review


#focus-slide[
  #image("images/chinese.jpg")
]

== Review exercises

Open the `rust-course-ghent` repo in you editor.

The review exercises are in sub-folder `session-3/examples/`.

Ordered by topic and by coverage in this series:

1. Traits basics and *orphan rule* (important)
2. Generics and supertrait bounds
3. Closures and functional programming (less important)
4. Standard library types and traits
5. Extra's (for prepared students)
  - based on additional questions students
  - useful for student projects

To test your solution (from anywhere): `cargo run --example [FILENAME_WITHOUT_EXT]`


Otherwise, you can do Rustlings exercises or start with your student project.


== Exercises Rustlings

(See https://rustlings.rust-lang.org/setup/)

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



#include "1-std-traits.typ"
#include "2-ownership.typ"

