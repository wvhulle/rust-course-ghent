#import "../template.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 1: Introduction],
    subtitle: [Patterns, methods, traits and generics],
    author: [Willem Vanhulle],
    date: [Tuesday November 4, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#title-slide()

#include "./1-course.typ"
#include "./2-types-values.typ"
#include "./3-control-flow.typ"
#include "./4-tuples-arrays.typ"
#include "./5-references.typ"
#include "./6-user-types.typ"
