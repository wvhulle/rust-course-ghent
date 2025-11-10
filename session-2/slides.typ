#import "../template.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 2: Traits],
    subtitle: [Methods, traits, functional programming and standard library],
    author: [Willem Vanhulle],
    date: [Tuesday November 11, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#title-slide()


#include "./1-quiz.typ"
#include "./2-pattern-matching.typ"
#include "./3-methods-traits.typ"
#include "./4-generics.typ"
#include "./5-closures.typ"
#include "./6-std-types.typ"




= Conclusion



#slide[


  Homework:
  - study the standard library API and helper functions of `Result`
  - study standard library traits
  - (optional) read the `unsafe` chapter of Blandy and discussion about making safe buffer


  Questions?

  Feel free to contact me:

  - Video meeting / email: #link("willemvanhulle@protonmail.com")
  - Phone: +32 479 080 252



]
