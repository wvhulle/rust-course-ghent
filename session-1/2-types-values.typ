#import "../template.typ": *
= Types and Values

== Hello, world!

#slide[

  ```rust
  fn main() {
      println!("Hello, world!");
  }
  ```

  #pause

  - `fn` defines a function
  - Statements end with `;`
  - `main` is the entry point
  - Rust strings are UTF-8 encoded and can contain any Unicode character.

  #pause

  #qa[What does the `!` in `println!` signify?][It's a macro, not a function. Macros expand at compile time and can take variable arguments.]

  #pause

  #qa[Can you call `println!` without any arguments?][No, it requires at least a format string: `println!("")` or use `println!()` in newer Rust versions.]
]


== Variables

#slide[

  Type safety with static typing:

  ```rust
  fn main() {
    let x: i32 = 10;
    println!("x: {x}");
    // x = 20;
    // println!("x: {x}");
  }
  ```

  #pause

  #qa[What happens if we uncomment the two lines?][Variables are immutable by default. Use `mut` to make them mutable.]

  #pause

  #qa[Are type annotations required?][Not required for local variables (if the compiler *can infer*).]

]

== Values

#slide[
  Basic built-in types:

  - Signed integers: `i8`, `i16`, `i32`, `i64`, `i128`, `isize`
  - Unsigned integers: `u8`, `u16`, `u32`, `u64`, `u128`, `usize`
  #pause
  #qa[When should you use `isize` and `usize`?][Use `usize` for pointers and array indices.]
  #pause
  - Floating point: `f32`, `f64`
  - Boolean: `bool` (`true` or `false`)
  #pause
]
#slide[
  Does this compile?
  ```rust
  fn main() {
      let x: i32 = 5;
      let y: i64 = x;
  }
  ```

  #qa[Can you compare values of different numeric types directly (e.g., `i32` and `i64`)?][No! Rust has no implicit type conversions. You must use explicit casts with `as`: `x as i64 == y`]
  #pause
  - Character: `char`, written `'x'` (Unicode scalar value, 4 bytes)

  #warning[Every cast that may lose precision must be explicit with `as`!]

]


== Arithmetic

#slide[
  ```rust
  fn interproduct(a: i32, b: i32, c: i32) -> i32 {
    return a * b + b * c + c * a;
  }

  fn main() {
      println!("result: {}", interproduct(120, 100, 248));
  }
  ```

  #pause

  #qa[What happens when integer overflow occurs?][ It is defined behavior in release mode (wrap around), but panics in debug mode.]
]


== Question

#slide[


  ```rust
  fn main() {
      let mut x = 4;
      --x;
      print!("{}{}", --x, --x);
  }
  ```

  #qa[What is the output of this program?][Short answer: 4. Longer answer: Rust does not have a unary increment or decrement operator.]
]

== Type Inference

#slide(composer: (1fr, 1fr))[

  #set text(0.8em)

  ```rust
    fn takes_u32(x: u32) {
      println!("u32: {x}");
    }

    fn takes_i8(y: i8) {
        println!("i8: {y}");
    }

    fn main() {
        let x = 10;
        let y = 20;

        takes_u32(x);
        takes_i8(y);
        // takes_u32(y);
    }
  ```
][
  #pause

  #qa[Does this code compile?][Yes, Rust infers `x` as `u32` and `y` as `i8`.]

  #pause

  #qa[What happens if we uncomment the last line?][It does not compile: type mismatch.]

  #pause

  #qa[What is the default integer type in Rust?][It is `i32` unless otherwise specified.]
]





#focus-slide[
  #image("images/pingala.jpg")


]


#slide[
  #qa[Who was Pingala?][An ancient Indian scholar (circa 200 BC) who described the Fibonacci sequence in his work on prosody.]]

== Exercise: Fibonacci

#slide(composer: (1fr, 1fr))[

  ```rust
  fn fib(n: u32) -> u32 {
    if n < 2 {
        // The base case.
        return todo!("Implement this");
    } else {
        // The recursive case.
        return todo!("Implement this");
    }
  }


  ```
][
  #info[  The Fibonacci sequence begins with [0, 1]. For n > 1, the next number is the sum of the previous two.]
]



#slide[

  ```rust
  fn main() {
      let n = 20;
      println!("fib({n}) = {}", fib(n));
  }
  ```

  #qa[  When will this function panic?][
    - When `n` is too large and the result overflows `u32`.
    - When recursion depth exceeds the stack size (around 10,000).
  ]

  #pause

  #qa[How to fix these issues?][
    - Make it iterative.
    - Use `u128` or external `bigint` crate for large Fibonacci numbers.
  ]


]


