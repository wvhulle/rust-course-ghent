#import "../template.typ": *

= Quiz about last lecture

#focus-slide[
  #image("images/no_pain_no_gain.jpg")

]


== Comparing pointers

=== Question

```rust
struct S;

fn main() {
    let [x, y] = &mut [S, S];

    let eq = x as *mut S == y as *mut S;
    print!("{}", eq as u8);
}
```

#qa[What does this program print?][...]


#slide[
  === Explanation
  #set text(size: 0.6em)

  #qa[What are zero-sized types?][Types that occupy no space at runtime.]

  #fletcher-diagram(
    spacing: (12em, 0em),
    node((0, 0), width: 23em, name: <original>, [
      ```rust
      struct S;
      fn main() {
          let [x, y] = &mut [S, S];
          let eq = x as *mut S == y as *mut S;
          print!("{}", eq as u8);
      }
      ```
    ]),

    pause,
    edge(<original>, <step1>, "->", label: [Desugaring array \ pattern match]),
    node((1, 0), width: 23em, name: <step1>, [
      ```rust
      fn main() {
          let tmp: [S; 2] = [S, S];
          let x = &mut tmp[0];
          let y = &mut tmp[1];
          let eq = x as *mut S == y as *mut S;
          print!("{}", eq as u8);
      }
      ```
    ]),
    pause,
    node((0, 1), width: 25em, name: <step2>, [
      ```rust
      fn main() {
          let tmp: [S; 2] = [S, S];
          let x = &mut tmp[0];
          let y = &mut tmp[1];
          let eq = (x as *mut S) == (y as *mut S);
          print!("{}", eq as u8);
      }
      ```
    ]),
    edge(<step1>, <step2>, "->", label: [Operator `==` precedence\ above cast with `as`]),
    pause,
    node((1, 1), width: 20em, name: <step3>, [
      ```rust
      fn main() {
          let tmp: [S; 2] = [S, S];
          let x = &mut tmp[0];
          let y = &mut tmp[1];
          let x_ptr: *mut S = x;
          let y_ptr: *mut S = y;
          let eq = x_ptr == y_ptr;
          print!("{}", eq as u8);
      }
      ```
    ]),
    edge(<step2>, <step3>, "->", label: [Explicit casts]),
  )

  #qa[Are `x_ptr` and `y_ptr` equal?][Yes, since the compiler can see that `S` is a zero-sized type.]
]


== Patterns

=== Question

Last session I mentioned that variable assignments are actually patterns.


```rust
fn main() {
    let (.., x, y) = (0, 1, ..);
    print!("{}", b"066"[y][x]);
}
```

#qa[What does this program print?][...]

#pagebreak()

#slide[
  #set text(size: 0.8em)
  === Explanation

  #fletcher-diagram(
    spacing: (10em, 1em),
    node(
      (1, 0),
      [
        ```rust
        fn main() {
            let (.., x, y) = (0, 1, ..);
            print!("{}", b"066"[y][x]);
        }
        ```
      ],
      width: 18em,
      name: <original>,
    ),
    pause,
    node(
      (2, 0),
      width: 18em,
      [
        ```rust
        fn main() {
           let x = 1;
           let y: RangeFull = ..;
           print!("{}", b"066"[y][x]);
        }
        ```

      ],
      name: <step1>,
    ),
    edge(<original>, <step1>, "->", label: [Desugaring `..` \ as a range]),
    pause,
    node(
      (1, 1),
      width: 22em,
      name: <step2>,
      [

        ```rust
        fn main() {
           let x = 1;
           let y = ..;
           let bytes: &'static [u8; 3] = b"066";
           print!("{}", bytes[..][x]);
        }
        ```

      ],
    ),
    edge(<step1>, <step2>, "->", label: [Explicit type \ binary literal]),
    pause,
    node(
      (2, 1),
      width: 16em,
      [


        ```rust
        fn main() {
           let x = 1;
           let bytes = b"066";
           print!("{}", bytes[x]);
        }
        ```
      ],
      name: <step3>,
    ),
    edge(<step2>, <step3>, "->", label: [Slice\ indexing]),
  )

  #qa[What is the decimal representation of the ASCII character '6'?][54]
]

== Bool

#slide[
  #set text(size: 0.8em)
  === Question



  ```rust
  fn check(x: i32) -> bool {
      print!("{}", x);
      false
  }

  fn main() {
      match (1, 2) {
          (x, _) | (_, x) if check(x) => {
              print!("3")
          }
          _ => print!("4"),
      }
  }
  ```
  #qa[What does this program print?][...]
]


#slide[
  #set text(size: 0.65em)
  === Explanation

  #fletcher-diagram(
    spacing: (1em, 1em),
    node(
      (0, 0),
      width: 20em,
      name: <original>,
      [
        ```rust
        fn check(x: i32) -> bool {
            print!("{}", x);
            false
        }
        ```
      ],
    ),
    pause,

    node(
      (1, 0),
      width: 22em,
      name: <step1>,
      [
        #codly(
          highlights: (
            (line: 2, start: 5, end: 16),
          ),
        )
        ```rust
        fn main() {
            match (1, 2) {
                (x, _) | (_, x) if check(x) => {
                    print!("3")
                }
                _ => print!("4"),
            }
        }
        ```
      ],
    ),
    edge(<original>, <step1>, "->"),
    pause,

    node(
      (2, 0),
      width: 22em,
      name: <step2>,
      [
        #codly(
          highlights: (
            (line: 3, start: 9, end: 14, fill: red),
            (line: 3, start: 25, end: 35, fill: orange),
          ),
        )
        ```rust
        fn main() {
            match (1, 2) {
                (x, _) | (_, x) if check(x) => {
                    print!("3")
                }
                _ => print!("4"),
            }
        }
        ```
      ],
    ),
    edge(<step1>, <step2>, "->"),
    pause,
    node(
      (0, 1),
      width: 22em,
      name: <step3>,
      [
        #codly(
          highlights: (
            (line: 2, start: 5, end: 19, fill: red),
            (line: 3, start: 5, fill: orange),
          ),
        )
        ```rust
        fn check(x: i32) -> bool {
            print!("{}", x);
            false
        }
        ```
      ],
    ),
    edge(<step2>, <step3>, "->"),
    pause,
    node(
      (1, 1),
      width: 22em,
      name: <step4>,
      [
        #codly(
          highlights: (
            (line: 3, start: 18, end: 23, fill: red),
            (line: 3, start: 25, end: 35, fill: orange),
          ),
        )
        ```rust
        fn main() {
            match (1, 2) {
                (x, _) | (_, x) if check(x) => {
                    print!("3")
                }
                _ => print!("4"),
            }
        }
        ```
      ],
    ),
    edge(<step3>, <step4>, "->"),
    pause,
    node(
      (2, 1),
      width: 22em,
      name: <step5>,
      [
        #codly(
          highlights: (
            (line: 4, start: 13, end: 23, fill: red),
          ),
        )
        ```rust
        fn main() {
            match (1, 2) {
                (x, _) | (_, x) if check(x) => {
                    print!("3")
                }
                _ => print!("4"),
            }
        }
        ```
      ],
    ),
    edge(<step4>, <step5>, "->"),
  )

  #qa[What is going on here?][the guard is being run multiple times, once per `|`-separated alternative in the match-arm.]
]
