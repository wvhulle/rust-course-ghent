#import "../template.typ": *
= Tuples and arrays

== Arrays

#slide[

  #info[Arrays are fixed-size, *fixed-length contiguous collections* located on the stack]

  #pause

  ```rust
  fn main() {
      let mut a: [i8; 5] = [5, 4, 3, 2, 1];
      a[2] = 0;
      println!("a: {a:?}");
  }
  ```

  #pause

  #qa[Can you omit the length of the array in the type annotation?][Yes, the compiler can *infer it from the initializer*. In other cases, it is required.]

]


#slide[

  ```rust
  fn main() {
      let mut a: [i8; 5] = [5, 4, 3, 2, 1];
      a[6] = 0;
      println!("a: {a:?}");
  }
  ```

  #qa[What happens when we run this program?][It panics at runtime: index out of bounds. Rust performs *bounds checking* on array accesses at runtime.]

  #pause

  #warning[If possible, the compiler omits the bound checks. They may also be disabled explicitly by user.]
]

#slide[
  Have a look at this code:

  ```rust
  fn get_index() -> usize { 6 }
  fn main() {
      let mut a: [i8; 5] = [5, 4, 3, 2, 1];
      a[get_index()] = 0;
      println!("a: {a:?}");
  }
  ```


  #qa[Will the compiler implement run-time bounds checks?][Yes, because the index is not known at compile time.]

  #pause

  #info[You could write `const fn get_index() -> usize { 6 }` to make it a compile-time constant and remove the runtime bounds check.]

]

#slide[

  #info[All arrays have a fixed size known at compile time.]

  #pause

  #warning[All arrays are stored on the stack by default.]


  #pause

  #qa[Can the length of an array be modified at runtime?][No, but you can have arrays with mutable elements.]

  ```rust
  let mut a: [i8; 5] = [5, 4, 3, 2, 1];
  a[2] = 0;
  ```
]

== Debug output

#slide[


  Printing arrays for debugging:

  ```rust
  fn main() {
      let a: [i8; 5] = [5, 4, 3, 2, 1];
      println!("a: {:?}", a);
  }
  ```

  #pause

  #qa[What does the `:?` format specifier do?][It uses the `Debug` trait to format the value for debugging purposes. (Also used by `dbg!` and `eprintln!` macros.)]

]

== Tuples

#slide[

  Grouping values (of different types) without field names:

  ```rust
  fn main() {
      let t: (i8, bool) = (7, true);
      dbg!(t.0);
      dbg!(t.1);
  }
  ```
  #pause



  #warning(title: [Tuples are limited])[

    - You cannot use them in `for` loops.
    - You cannot change their length.
    - You cannot access elements by name.
    - You cannot use array indexing syntax (e.g., `t[0]`).
  ]

]

== Array iteration

#slide[

  Arrays are iterable.

  ```rust
  fn main() {
      let primes = [2, 3, 5, 7, 11, 13, 17, 19];
      for prime in primes {
          for i in 2..prime {
              assert_ne!(prime % i, 0);
          }
      }
  }
  ```
]


== Patterns and destructuring

#slide[
  #set text(size: 0.8em)

  You can destructure tuples and arrays with *destructuring patterns*:

  ```rust
  fn check_order(tuple: (i32, i32, i32)) -> bool {
      let (left, middle, right) = tuple;
      left < middle && middle < right
  }

  fn main() {
      let tuple = (1, 5, 3);
      println!(
          "{tuple:?}: {}",
          if check_order(tuple) { "ordered" } else { "unordered" }
      );
  }
  ```


  #info[
    An irrefutable destructuring pattern is a pattern that *always matches*.]
]

== Exercise: nested arrays

#slide[
  #set text(0.8em)

  Implement a matrix transpose function that works on 3x3 matrices:

  $
    mat(
      1, 2, 3;
      4, 5, 6;
      7, 8, 9;
    ) ->
    mat(
      1, 4, 7;
      2, 5, 8;
      3, 6, 9;
    )
  $

  ```rust
  fn transpose(matrix: [[i32; 3]; 3]) -> [[i32; 3]; 3] {
      todo!()
  }
  ```
  Find the exercise here: `session-1/examples/s1e3-transpose.rs`.

]




