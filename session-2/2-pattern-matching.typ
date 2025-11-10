#import "../template.typ": *



= Pattern matching

== Irrefutable patterns

#slide[
  #set text(size: 0.8em)

  #info[
    An *irrefutable pattern* is a pattern that always matches.]

  #grid(columns: (1fr, 1fr), column-gutter: 2em)[

    ```rust
    fn takes_tuple(tuple: (char, i32, bool)) {
        let a = tuple.0;
        let b = tuple.1;
        let c = tuple.2;

        // This does the same thing as above.
        let (a, b, c) = tuple;

        // Ignore the first element, only bind the second and third.
        let (_, b, c) = tuple;

        // Ignore everything but the last element.
        let (.., c) = tuple;
    }
    ```
  ][
    #pause

    #qa[What happens when adding or removing an element to the tuple and look at the resulting compiler errors][The destructuring pattern must match the structure of the value exactly.]

    #pause

    #info[A variable binding is actually a pattern itself!]


    The `_` pattern matches anything.

  ]
]

#slide[
  === Advanced usage of `..`

  Ignoring middle element:
  ```rust
  fn takes_tuple(tuple: (char, i32, bool, u8)) {
      let (first, .., last) = tuple;
  }
  ```
  #pause
  Works with arrays as well:
  ```rust
  fn takes_array(array: [u8; 5]) {
    let [first, .., last] = array;
  }
  ```

  #pause
  #warning[Pattern matching works on all data types in Rust!]
]

== Matching values

#slide[
  Patterns can also be simple values like characters:

  ```rust
  #[rustfmt::skip]
  fn main() {
      let input = 'x';
      match input {
          'q'                       => println!("Quitting"),
          'a' | 's' | 'w' | 'd'     => println!("Moving around"),
          '0'..='9'                 => println!("Number input"),
          key if key.is_lowercase() => println!("Lowercase: {key}"),
          _                         => println!("Something else"),
      }
  }
  ```
  A variable in the pattern (key in this example) will create a binding that can be used within the match arm.


]

#slide[
  A *match guard*:

  - causes the arm to match only if the condition is true.
  - If the condition is false the match will continue checking later cases.

  ```rust
  #[rustfmt::skip]
  fn main() {
      let input = 'a';
      match input {
          key if key.is_uppercase() => println!("Uppercase"),
          key => if input == 'q' { println!("Quitting") },
          _   => println!("Lowercase"),
      }
  }
  ```

  #qa[What is the bug in this program?][The second arm will always match, so the third arm is unreachable. Write match guard in front of the second arm: `key if key == 'q' => ...`]

]

#slide[

  #warning[*Can't use an existing variable* as the condition in a match arm, as it will instead be interpreted as a variable name pattern, which creates a new variable that will shadow the existing one.]

  ```rust
  let expected = 5;
  match 123 {
      expected => println!("Expected value is 5, actual is {expected}"),
      _ => println!("Value was something else"),
  }
  ```

  #qa[What is the output of this program?][Will always print "Expected value is 5, actual is 123".]

]

#slide[

  Use `@` to bind to a value while also testing it:

  ```rust
  let expected = 5;
  match 123 {
      val @ 1..=10 => println!("Value {val} is between 1 and 10"),
      val @ 11..=20 => println!("Value {val} is between 11 and 20"),
      val => println!("Value {val} is something else"),
  }
  ```

]

== Practice: Rustlings Enums

#slide[
  #set text(size: 0.9em)

  Practice basic enums and pattern matching:

  *Rustlings exercises*:
  - `exercises/08_enums/enums1.rs` - Define basic enums
  - `exercises/08_enums/enums2.rs` - Enums with associated data
  - `exercises/08_enums/enums3.rs` - Pattern matching with enums


  Online: #link("https://github.com/rust-lang/rustlings")
]

== Structs

Like tuples, structs can also be destructured by matching:

```rust
struct Foo {
    x: (u32, u32),
    y: u32,
}

#[rustfmt::skip]
fn main() {
    let foo = Foo { x: (1, 2), y: 3 };
    match foo {
        Foo { y: 2, x: i }   => println!("y = 2, x = {i:?}"),
        Foo { x: (1, b), y } => println!("x.0 = 1, b = {b}, y = {y}"),
        Foo { y, .. }        => println!("y = {y}, other fields were ignored"),
    }
}
```

Add or remove fields to `Foo` and see what happens!

=== Reference patterns

When matching on a reference, Rust *automatically dereferences* it for you:

#codly(
  highlights: ((line: 3, start: 11, end: 14),),
)
```rust
fn main() {
    let foo = Foo { x: (1, 2), y: 3 };
    match &foo {  // `foo` is turned into a reference
        Foo { y: 2, x: i }   => println!("y = 2, x = {i:?}"),
        Foo { x: (1, b), y } => println!("x.0 = 1, b = {b}, y = {y}"),
        Foo { y, .. }        => println!("y = {y}, other fields were ignored"),
    }
}
```

#info[
  The pattern `Foo { ... }` works on `&foo` because Rust automatically dereferences. You could also write `&Foo { ... }` explicitly, but it's not required.
]

#slide[

  Two equivalent ways to match on a reference:

  ```rust
  match &foo {
      Foo { y, .. } => println!("y = {y}"),  // Implicit dereference
  }

  match &foo {
      &Foo { y, .. } => println!("y = {y}"), // Explicit dereference pattern
  }
  ```
  Pick the one you like best!

  #warning[
    In the implicit version, bound variables like `y` will be references. In the explicit version with `&Foo`, `y` will be a value (copied from the struct).
  ]
]


#slide[
  === Mutable reference patterns

  When matching on `&mut`, bound variables are mutable references:

  #codly(
    highlights: (
      (line: 7, start: 11, end: 18),
      (line: 8, start: 26, end: 26, fill: red),
      (line: 8, start: 33, end: 34, fill: orange),
    ),
  )
  ```rust
  struct Foo {
      x: (u32, u32),
      y: u32,
  }
  fn main() {
      let mut foo = Foo { x: (1, 2), y: 3 };
      match &mut foo {
          Foo { x: (1, 2), y } => *y = 4,  // y is &mut u32, need * to assign
          Foo { y, .. }        => println!("y = {y}"),
      }
  }
  ```

  #warning[
    Bound variables like `y` are `&mut u32`, not `u32`. You must dereference with `*` to assign values.
  ]
]

#slide[
  === Intuition


  #fletcher-diagram(
    node((0, 0), [Original \ object], name: <object>, fill: blue.lighten(70%)),

    node((1, -1), [`&foo`], name: <shared>),
    edge(<object>, <shared>, "->", [shared]),
    node((1, 1), [`&mut foo`], name: <exclusive>),
    edge(<object>, <exclusive>, "->", [exclusive]),

    edge(<object>, <shared>, [shared]),

    edge(<object>, <exclusive>, [exclusive]),
    pause,
    node((2, -1), [`match &foo`], name: <shared-match>),
    edge(<shared>, <shared-match>, "->"),
    node((2, 1), [`match &mut foo`], name: <exclusive-match>),
    edge(<exclusive>, <exclusive-match>, "->"),
    pause,
    node((3, -1.8), name: <top-border>),
    node((3, 1.8), name: <bottom-border>),
    edge(<top-border>, <bottom-border>, "=", stroke: gray, [_Match barrier_\  (for references)]),

    pause,

    node((4, -1.5), [`Foo { y, .. }` \ (`y` is `&u32`)], name: <shared-pattern>),
    edge(<shared-match>, <shared-pattern>, "->", bend: 10deg),
    node((4, 1.5), [`Foo { y, .. }` \ (`y` is `&mut u32`)], name: <exclusive-pattern>),
    edge(<exclusive-match>, <exclusive-pattern>, "->", bend: -10deg),
  ),


]

== Enums


#slide[
  #set text(size: 0.7em)
  Like tuples, enums can also be destructured by matching:
  ```rust
    enum Result {
        Ok(i32),
        Err(String),
    }

    fn divide_in_two(n: i32) -> Result {
        if n % 2 == 0 {
            Result::Ok(n / 2)
        } else {
            Result::Err(format!("cannot divide {n} into two equal parts"))
        }
    }
  ```
  #pause
  ```rs
  fn main() {
      let n = 100;
      match divide_in_two(n) {
          Result::Ok(half) => println!("{n} divided in two is {half}"),
          Result::Err(msg) => println!("sorry, an error happened: {msg}"),
      }
  }
  ```

  #warning[Rust does not allow non-exhaustive matches]
]


== Let control flow

#slide[
  #set text(size: 0.8em)
  ```rust
  use std::time::Duration;

  fn sleep_for(secs: f32) {
      let result = Duration::try_from_secs_f32(secs);

      if let Ok(duration) = result {
          std::thread::sleep(duration);
          println!("slept for {duration:?}");
      }
  }

  fn main() {
      sleep_for(-10.0);
      sleep_for(0.8);
  }
  ```

  #qa[When to use `if let` over `match`?][Use `if let` when you only care about one specific pattern and want to ignore all others.]

  // TODO: some slides  skipped
]

== Practice: Exercism Clock

#slide[


  *Exercism: Clock*:
  - Path: `exercises/practice/clock/`
  - Goal: Implement a clock that handles times without dates
  - Requires: Structs, methods, pattern matching with `match`


  Online: #link("https://exercism.org/tracks/rust/exercises/clock")
]

== Exercise: Expression evaluation

#slide[

  #warning[*Important Exercise*]

  Let's write a simple recursive evaluator for arithmetic expressions.

  Complete the `eval` function in the file `session-2/tests/s2e2-evaluation.rs`.

  Run tests with `cargo test --test s2e2-evaluation`.
]
