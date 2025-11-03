#import "../template.typ": *
= Control flow basics


== Blocks and scopes

#slide(composer: (1fr, 1fr))[

  ```rust
  fn main() {
    let z = 13;
    let x = {
        let y = 10;
        dbg!(y);
        z - y
    };
    dbg!(x);
    // dbg!(y);
  }
  ```][

  #pause

  #qa[What is the output of this program?][The output is `x = 3`.]

  #pause

  #qa[What happens if we uncomment the last line?][Would not compile because `y` is out of scope: de-allocated.]

  #pause

  #info[Rust is an *expression-based* language: almost everything is an expression that returns a value.]
]

== If expressions

#slide[
  ```rust
  fn main() {
      let x = 10;
      if x == 0 {
          println!("zero!");
      } else if x < 100 {
          println!("biggish");
      } else {
          println!("huge");
      }
  }
  ```

]

#slide[


  ```rust
  fn main() {
    let x = 10;
    let size = if x < 20 { "small" } else { "large" };
    println!("number size: {}", size);
  }
  ```

  #qa[What happens when we put a semicolon (`;`) behind the `"small"` string?][It does not compile.]


  #warning[Semi-colons at the end of block *suppress block return values*.]
]

== Match expressions


#slide(composer: (1.5fr, 1fr))[
  ```rust
  fn main() {
    let val = 1;
    match val {
        1 => println!("one"),
        10 => println!("ten"),
        100 => println!("one hundred"),
        _ => {
            println!("something else");
        }
    }
  }
  ```
][
  #pause


  #qa[What happens without the `_` case?][It does not compile: non-exhaustive patterns.]

  #warning[All possible cases must be handled in a `match` expression (exhaustiveness is required).]
]

#slide[
  #set text(size: 0.8em)
  ```rust
  fn main() {
    let flag = true;
    let val = match flag {
        true => 1,
        false => 0,
    };
    println!("The value of {flag} is {val}");
  }
  ```

  #pause

  #info[Every `match` is also an expression that returns a value.]

  #pause

  #warning[
    - All blocks are expressions! Arms may be blocks.
    - Do not put semi-colons at the end of arms if you want to return a value!
  ]
]


== Loops

#slide(composer: (1fr, 1fr))[

  ```rust
  fn main() {
      let mut x = 200;
      while x >= 10 {
          x = x / 2;
      }
      dbg!(x);
  }
  ```

  #info[`break`, `continue` and `return` work as expected. `loop` is `while true`.]
]

#slide[

  ```rust
  fn main() {
      for x in 1..5 {
          dbg!(x);
      }

      for elem in [2, 4, 8, 16, 32] {
          dbg!(elem);
      }
  }
  ```

  #pause

  #qa[What can we write inside the `in` of a `for` loop?][Any iterable type. Implemented with `IntoIterator` trait (see later).]

]

== Functions

#slide[

  ```rust
  fn gcd(a: u32, b: u32) -> u32 {
      if b > 0 { gcd(b, a % b) } else { a }
  }

  fn main() {
      dbg!(gcd(143, 52));
  }
  ```

  #qa[What is the return type of `main`?][It is `()`, the *unit type* (like `void` in C/C++) and optional.]

  #pause

  #qa[How would you achieve function overloading in Rust?][Rust doesn't support traditional overloading. Instead, use: different names, generic functions with trait bounds, or method overloading through traits like `Add` or `From`.]
]

== Macros

#slide(composer: (1fr, 1fr))[

  - `println!(format)` prints to standard output with formatting.
  - `dbg!(expr)` prints the value of `expr` to standard error for debugging.
  - `todo!()` panics with a "not yet implemented" message.

  #pause

  #qa[Which macros should you use in tests?][
    - `assert!(condition)` to check if a condition is true.
    - `assert_eq!(a, b)` to check if two values are equal.
  ]
][
  ```rust
  fn factorial(n: u32) -> u32 {
      let mut product = 1;
      for i in 1..=n {
          product *= dbg!(i);
      }
      product
  }
  fn main() {
      let n = 4;
      println!("{n}! = {}", factorial(n));
  }
  ```
]



== Exercise: Collatz sequence

#slide[

  The Collatz Sequence is defined as follows, for an arbitrary n1 greater than zero:

  - If n is even, the next number in the sequence is n / 2
  - If n is odd, the next number in the sequence is 3n + 1
  - The sequence ends when it reaches 1.


  Determine the length of the collatz sequence beginning at `n`.
  ```rust
  fn collatz_length(mut n: i32) -> u32 { todo!("Implement this") }

  fn main() {
      println!("Length: {}", collatz_length(11)); // should be 15
  }
  ```
]

#slide[
  Possible solution:

  ```rust
  fn collatz_length(mut n: i32) -> u32 {
      let mut len = 1;
      while n > 1 {
          n = if n % 2 == 0 { n / 2 } else { 3 * n + 1 };
          len += 1;
      }
      len
  }
  ```

]

