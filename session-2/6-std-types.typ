#import "../template.typ": *

= Standard library types

== Overview

#slide[
  #set align(center + horizon)
  #fletcher-diagram(
    node-shape: shapes.circle,
    node((0, 0), fill: green.lighten(70%), width: 17em),
    node((0, 1), [`std`], name: <std>),
    node((0, 0), [`alloc`], fill: purple.lighten(70%), width: 9em),
    node((0, 0.5), [`alloc`], name: <alloc>),
    node((0, 0), [`core`], name: <core>, fill: blue.lighten(70%), width: 3em),


    pause,

    node((2, -1), [Primitives\ `Option`, `Result`, `bool`, `array`, ...\ `fmt`, `panic`, ...], name: <primitives>),

    edge(<core>, <primitives>, "->", label: [Includes], layer: 1),
    pause,


    node((2, 0), [Collections\ `Vec`, `String`, `Box`, ...\ `Rc`, `Arc`, ...], name: <collections>),

    edge(<alloc>, <collections>, "->", label: [Includes], layer: 1),
    pause,

    node((2, 1), [Operating system interaction\ `fs`, `TcpStream`, `io`, ...\ `thread`, `process`, ...], name: <os>),
    edge(<std>, <os>, "->", label: [Includes], layer: 1),
  )
]


#slide[

  It is good style to prefer the minimal amount of imports:

  - If it is available in `core`, use that
  - Else, if it is available in `alloc`, use that
  - Else, use `std`

  #pause

  #qa[What would be a practical way to enforce this?][Forbid certain lints in your `Cargo.toml` file.]


  ```toml
  [lints.clippy]
  alloc_instead_of_core = "deny"
  std_instead_of_alloc = "deny"
  std_instead_of_core = "deny"
  ```
]


== Documentation resources

#slide[

  Locally:

  - `rustup doc --std` (opens standard library docs)
  - `cargo doc --open`
  - `cargo doc --open --no-deps` (only your code)

  Try these commands out!

  #pause

  Online:
  - https://doc.rust-lang.org/stable/std/
  - https://std.rs


]


== Creating documentation



#slide[

  === Funtion documentation
  You can add "doc-comments" to your code using triple slashes `///`:

  ```rust
  /// Determine whether the first argument is divisible by the second argument.
  ///
  /// If the second argument is zero, the result is false.
  fn is_divisible_by(lhs: u32, rhs: u32) -> bool {
      if rhs == 0 {
          return false;
      }
      lhs % rhs == 0
  }
  ```

  Will be shown when you run `cargo doc --open` (or hover over the function in your editor).
]

#slide[
  === More doc-comment positions

  Enum variants and struct fields can be documented too:

  ```rust
  /// A simple enum.
  enum MyEnum {
      /// The first variant.
      VariantA,
      /// The second variant.
      VariantB,
  }
  ```
]


#slide[
  #set text(size: 0.9em)
  === Documenting modules

  To document the module containing the current definition, use `//!` comments at the top of the file:

  ```rust
  //! This module contains utility functions for mathematical operations.
  pub fn add(a: i32, b: i32) -> i32 {
      a + b
  }
  ```

  All text in `///` or `//!` comments supports Markdown.

  You can even *write unit tests in doc-comments* that are checked when you run `cargo test`!

  #codly(
    highlights: (
      (line: 6, start: 5, end: 22, fill: blue.lighten(50%)),
    ),
  )
  #raw(
    block: true,
    "/// Adds two numbers together.
///
/// # Examples
/// ```
/// let sum = add(2, 3);
/// assert_eq!(sum, 5);
/// ```",
  )
]

#slide[
  === Demonstration

  Every library that you publish receive automatic documentation on `docs.rs`.

  See for example:

  - #link("https://docs.rs/clone-stream/0.4.0/clone_stream/")
  - #link("https://docs.rs/rand/latest/rand/")

  Every public crate has a link to the documentation.
]

== The `Option` type

#slide[

  `Option` is part of `core` and represents an optional value:

  #codly(
    highlights: (
      (line: 3, start: 39, end: 53, fill: red),
    ),
  )
  ```rs
  fn main() {
      let name = "Löwe 老虎 Léopard Gepardi";
      let mut position: Option<usize> = name.find('é');
      dbg!(position);
      assert_eq!(position.unwrap(), 14);
      position = name.find('Z');
      dbg!(position);
      assert_eq!(position.expect("Character not found"), 0);
  }
  ```

  `String::find` returns `Option`. Unwrapping an `Option` that is `None` *will cause a panic*.

  #qa[Is it possible to forget handling a `None` case?][No, the compiler forces you to handle both cases.]
]

#slide[

  === Use cases for `Option`

  `Option` is really about data or information that might be absent.

  #warning[The `Option::None` variant should *not replace every `null`* value in other languages!]

  In most cases, you should declare a custom enum:

  ```rust
  enum LoginResult {
      Success(UserData),
      InvalidPassword,
      UserNotFound,
  }
  ```
  #qa[Why would it be better to use a custom enum instead of `Option<UserData>`?][A custom enum can provide more context about why the data is absent]

]

#slide[
  === Relationship `bool` and `Option`

  The standard library API entangles `bool` and `Option` in interesting ways.


  #pause

  `bool::then()` converts a boolean to an `Option`:
  ```rust
  let is_valid = true;
  assert_eq!(is_valid.then(|| 42), Some(42));

  let is_invalid = false;
  assert_eq!(is_invalid.then(|| 42), None);
  ```

  #pause

  `and()` combines `Option`s like boolean AND (`&&`):
  ```rust
  let x = Some(2);
  let y: Option<i32> = None;
  assert_eq!(x.and(y), None);  // Returns None if either is None
  ```
]

#slide[




  #qa[What is the "niche optimisation" in the context of `Option`?][Certain types have unused bit patterns (niches) that can be used to represent `None` without extra space.]

  === The actual machine representation


  We'll use `transmute` to peek at the internal bit representation:

  #codly(
    highlights: (
      (line: 4, start: 49),
    ),
  )
  ```rust
  use std::mem::transmute;
  macro_rules! dbg_bits {
      ($e:expr, $bit_type:ty) => {
          println!("- {}: {:#x}", stringify!($e), transmute::<_, $bit_type>($e));
      };
  }
  ```

  For every expression, what is its bit representation (as a hexadecimal number)?

  #pause

  #warning[`transmute` is unsafe and reinterprets memory.]
]

#slide(composer: (1fr, 1fr))[

  === Representation of `bool` and `Option<bool>`

  ```rust
  unsafe {
      println!("bool:");
      dbg_bits!(false, u8);
      dbg_bits!(true, u8);

      println!("Option<bool>:");
      dbg_bits!(None::<bool>, u8);
      dbg_bits!(Some(false), u8);
      dbg_bits!(Some(true), u8);
  }
  ```
][
  Expected output:
  ```
  bool:
  - false: 0x0
  - true: 0x1
  Option<bool>:
  - None::<bool>: 0x2
  - Some(false): 0x0
  - Some(true): 0x1
  ```

  #info[`Option<bool>` uses `0x2` for `None`, allowing all three states in 1 byte!]
]

#slide(composer: (1fr, 1fr))[

  === Representation of `Option<Option<bool>>`

  ```rust
  unsafe {
      println!("Option<Option<bool>>:");
      dbg_bits!(Some(Some(false)), u8);
      dbg_bits!(Some(Some(true)), u8);
      dbg_bits!(Some(None::<bool>), u8);
      dbg_bits!(None::<Option<bool>>, u8);
  }




  ```][

  Expected output:
  ```
  Option<Option<bool>>:
  - Some(Some(false)): 0x0
  - Some(Some(true)): 0x1
  - Some(None::<bool>): 0x2
  - None::<Option<bool>>: 0x3
  ```

  #info[Four distinct states, still fitting in just 1 byte!]
]

#slide(composer: (1fr, 1fr))[

  === `Option<&i32>` and null pointer optimization

  ```rust
  unsafe {
      println!("Option<&i32>:");
      dbg_bits!(None::<&i32>, usize);
      dbg_bits!(Some(&0i32), usize);
  }




  ```][

  Expected output (on 64-bit):
  ```
  Option<&i32>:
  - None::<&i32>: 0x0
  - Some(&0i32): 0x7ffc8e4a1b2c
  ```

  #info[`None` is represented as null pointer (`0x0`), while `Some` contains the actual memory address. No extra space needed for the discriminant!]
]

#focus-slide[
  #image("images/write_macros.jpg")
]


== `Result` type

#slide[
  #set text(size: 0.8em)
  ```rs
  use std::fs::File;
  use std::io::Read;

  fn main() {
      let file: Result<File, std::io::Error> = File::open("diary.txt");
      match file {
          Ok(mut file) => {
              let mut contents = String::new();
              if let Ok(bytes) = file.read_to_string(&mut contents) {
                  println!("Dear diary: {contents} ({bytes} bytes)");
              } else {
                  println!("Could not read file content");
              }
          }
          Err(err) => {
              println!("The diary could not be opened: {err}");
          }
      }
  }
  ```
]


=== Interpretation

`Result` is similar to `Option`, but indicates the success or failure of an operation.

#pause

`Result` is generic: `Result<T, E>` where:

- `T` is used in the `Ok` variant and
- `E` appears in the `Err` variant.


#warning(title: [Rule of thumb])[Use `Result` instead of `Option` when the reason of failure needs different handling.]





#qa[What do `Result` and `Option` have in common?][They *may short-circuit* the execution of a function.]

#qa[What is the name for a object that has short-circuiting behaviour?][A Monad.]


#focus-slide[

  #image("images/monad.jpg")
]


== Heap allocation

#slide[



  #warning[We have not yet done any heap allocation!]

  #set align(center + horizon)
  #fletcher-diagram(
    node-shape: rect,
    spacing: (15mm, 8mm),

    // Stack section
    node((0, 0), [*Stack*], stroke: none, name: <stack-title>),
    node((0, 1), [`main()` frame\ `x: i32 = 5`], fill: blue.lighten(80%), name: <frame1>),
    node((0, 2), [`foo()` frame\ `y: bool = true`], fill: blue.lighten(80%), name: <frame2>),
    node((0, 3), [`bar()` frame\ `s: Box<...>`], fill: blue.lighten(80%), name: <frame3>),

    // Stack pointer indicator
    node((0, 4), [Stack pointer ↓], stroke: none, name: <sp>),

    edge(<frame1>, <frame2>, "->", stroke: 2pt + blue),
    edge(<frame2>, <frame3>, "->", stroke: 2pt + blue),
    edge(<frame3>, <sp>, "->", stroke: 2pt + blue, label: [Grows], label-side: right),

    node(enclose: (<frame1>, <frame2>, <frame3>, <sp>), stroke: blue),

    // Heap section
    node((3, 0), [*Heap*], stroke: none, name: <heap-title>),
    node((3, 1.5), [Allocated\ block], fill: orange.lighten(70%), width: 15mm, name: <heap1>),
    node((4, 2.8), [Free\ space], fill: gray.lighten(80%), width: 12mm, name: <free1>),
    node((2.5, 3.2), [Allocated\ block], fill: orange.lighten(70%), width: 15mm, name: <heap2>),
    node((3.8, 1), [Free\ space], fill: gray.lighten(80%), width: 10mm, name: <free2>),

    // Pointer from stack to heap
    edge(<frame3>, <heap2>, "->", stroke: 2pt + red, label: [Points to], label-side: center, bend: 20deg),

    // Annotations
    node((-1, 4), [Fast: pointer bump\ Fixed max size], stroke: none, fill: none),
    node((3, 4), [Slower: search & bookkeeping\ Dynamic size], stroke: none, fill: none),

    node(enclose: (<heap1>, <free1>, <heap2>, <free2>), label: [Heap memory area], stroke: orange),
  )
]



== `String`
`String` is a growable UTF-8 encoded string:
```rs
fn main() {
    let mut s1 = String::new();
    s1.push_str("Hello");
    println!("s1: len = {}, capacity = {}", s1.len(), s1.capacity());

    let mut s2 = String::with_capacity(s1.len() + 1);
    s2.push_str(&s1);
    s2.push('!');
    println!("s2: len = {}, capacity = {}", s2.len(), s2.capacity());

    let s3 = String::from("🇨🇭");
    println!("s3: len = {}, number of chars = {}", s3.len(), s3.chars().count());
}
```

#slide[

  #qa[How is `String` stored internally?][Just a safe wrapper around a vector of bytes on the heap. ]

  - `String::new` returns a new empty string, use `String::with_capacity` when you know how much data you want to push to the string. #pause
  - `String::len` returns byte length (which can be different from its length in characters). #pause
  - `String::chars` returns an iterator over the actual characters.

  #warning[Note that a char can be different from what a human will consider a “character” due to grapheme clusters.]


  Most `String` methods are actually defined on the thing `String` "dereferences" to: `&str`!

  #qa[Do you remember what `&str` is?][A string slice, a view into a UTF-8 encoded string stored elsewhere.]
]
=== Creating strings

In practice, `String` instances are generated with the `to_string` or `into` method from compile-time static string slices:

```rs
let s1: String = "Hello, world!".to_string();
```




#pause
=== String interpolation

Always done with macros:

```rs
println!("s3: len = {}, number of chars = {}", s3.len(), s3.chars().count());
```

#pause

Try to use macros that do not allocate new string buffers like `write!`:

```rs
use std::fmt::Write;
let mut buffer = String::with_capacity(50);
write!(&mut buffer, "s3: len = {}, number of chars = {}", s3.len(), s3.chars().count()).unwrap();
```

The `Display` trait uses `write!` to display printable data. (A bit like `repr` in Python.)

== `Vec` type

This is *heap allocated* and almost the same as `String` but:

- without UTF grapheme cluster limitations
- with arbitrary data types

#pause

Example of the `heapless` version (not essential for this course):

```rs
use heapless::Vec; // fixed capacity `std::Vec`

// on the stack
let mut xs: Vec<u8, 8> = Vec::new(); // can hold up to 8 elements
xs.push(42)?;
assert_eq!(xs.pop(), Some(42));
```

Note that we need a compile-time `const` upper-bound on the storage size (8).


== Exercise

Please solve exercise `session-2/examples/s2d8-counter.rs`

