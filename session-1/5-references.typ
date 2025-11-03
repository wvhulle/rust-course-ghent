#import "../template.typ": *

= References

== Shared references

#slide[

  #fletcher-diagram(
    node((0, 0), stroke: blue, [Reference `&T`], name: <ref>),
    edge(<ref>, <obj>, "->"),
    pause,
    node((1, 0), [*Referrent* `T`], name: <obj>),
  )

  ```rust
  fn main() {
      let a = 'A';
      let b = 'B';
      let mut r: &char = &a;
      dbg!(r);
  }
  ```

  #pause

  #qa[How is `r` displayed in the output?][It shows the value pointed to: `'A'`.]

  #pause

  #qa[How can we print the reference itself (the memory address)?][Use `println!("{r:p}")` or convert to raw pointer: `println!("{:p}", r as *const _)`]

]

#slide[

  #warning[Objects are shared immutably among different `&` through shared references.]

  ```rust
  fn main() {
      let mut c = 'C';
      let r: &char = &c;
      // *r = 'D';
      dbg!(r);
  }
  ```
  #pause

  #qa[What happens if we uncomment the line that tries to modify `*r`?][Objects cannot be modified through `&` references.]


]

== Dereferencing

#slide[

  References can be dereferenced automatically in certain cases.

  In C++, you would dereference like this:

  ```cpp
  char c = 'A';
  char* r = &c;
  std::cout << *r << std::endl;
  ```

  In Rust, you can just write:
  ```rust
  let c: char = 'A';
  let r: &char = &c;
  println!("{r}");
  ```

]

== Difficult question

#slide[

  #quote[What is the output of this Rust program?]


  ```rs
  fn main() {
      let a;
      let a = a = true;
      print!("{}", std::mem::size_of_val(&a));
  }
  ```

  #pause

  The variable `a` is shadowed by a new variable `a` which could be renamed `b`:

  ```rust
  let a;
  let b = a = true;
  print!("{}", mem::size_of_val(&b));
  ```



]

#slide[


  ```rust
  let a;
  let b = a = true;
  print!("{}", mem::size_of_val(&b));
  ```


  #qa[What is the output of this Rust program?][The value of an assignment is `()`.]

  We can rewrite the program as:

  ```rust
  let a = true;
  let b = ();
  print!("{}", mem::size_of_val(&b));
  ```

  The `size_of_val` gives the size of `()` (the referent).

  #qa[What is the size of `()`?][0 bytes.]
]

== Pointers

#slide[

  Every reference can be converted to a raw pointer, using a cast with `as`:

  ```rust
  let x: i32 = 10;
  let r: *const i32 = &x as *const i32;
  ```
  #info[
    Raw pointers are unsafe to dereference and require `unsafe` blocks.

    ```rust
    unsafe {
        println!("Value: {}", *r);
    }
    ```]
  #qa[Is every pointer a reference?][No. References have extra compile-time checks to *prevent dangling* pointers.]

  #qa[Is every reference a pointer?][Yes.]


]

== Exclusive references

#slide[
  #set text(0.8em)
  Also called mutable references.
  #info[*Exclusive references* (`&mut T`) allow mutation of the referenced object.]
  ```rust
  fn main() {
      let mut point = (1, 2);
      let x_coord = &mut point.0;
      // let y_coord = &mut point.1;
      *x_coord = 20;
      println!("point: {point:?}");
  }
  ```
  #qa[What happens if we uncomment?][Illegal: cannot borrow `point` as mutable more than once at a time.]

  #warning[One exclusive reference can exist at a time!]

]

== Exclusive vs. shared

#slide[

  Exclusive references cannot coexist with shared references.


  #fletcher-diagram(
    node((0, 0), stroke: blue, [Root object], name: <root>),

    edge((-2, 0.5), (2.5, 0.5), "-", stroke: gray),
    node((-2, 0), text(fill: gray)[Stage 1]),
    pause,
    node((-2, 1), text(fill: gray)[Stage 2]),
    edge(<root>, <shared>, "->"),
    node((1, 1), [Shared reference \ `&1`], name: <shared>, stroke: green),

    edge((-2, 1.5), (2.5, 1.5), "-", stroke: gray),
    edge(<root>, <excl>, "->"),
    node((-1, 1), [Exclusive reference \ `&mut 1`], stroke: orange, name: <excl>),

    edge(<shared>, <excl>, "<-/-/->", stroke: red),
    pause,

    edge(<excl>, <1excl>, "->"),
    node((-1.5, 2), [Passed], name: <1excl>),
    edge(<1excl>, <2excl>, "->"),
    node((-0.5, 3), [`&mut 1`], stroke: orange, name: <2excl>),

    edge((-2, 2.5), (2.5, 2.5), "-", stroke: gray),

    pause,
    node((-2, 3), text(fill: gray)[Stage 3]),
    edge(<shared>, <1shared>, "->"),
    node((1.5, 2), [Passed], name: <1shared>),
    edge(<shared>, <2shared>, "->"),
    node((.5, 2), [Copied], name: <2shared>),
    edge(<2shared>, <3shared>, "->"),
    node((1, 3), [`&2`], name: <3shared>, stroke: green),
    edge(<2shared>, <4shared>, "->"),
    node((1.5, 3), [`&3`], name: <4shared>, stroke: green),
    edge(<1shared>, <5shared>, "->"),
    node((2, 3), [`&1`], name: <5shared>, stroke: green),

    edge((-2, 3.5), (2.5, 3.5), "-", stroke: gray + 1pt),
  )
]

== Kinds of `mut`

#slide[



  ```rust
  let mut x_coord: &i32;
  let x_coord: &mut i32;
  ```

  #qa[What is the difference between these statements?][
    - `let mut x_coord: &i32;`: An immutable reference that can be reassigned to point to different `i32` values.
    - `let x_coord: &mut i32;`: An exclusive reference that allows modifying the `i32` value it points to.
  ]

  #info[Mutable references don't have to be assigned to `mut` variables to be able to mutate the referenced value.]
]



#slide[
  There used to be discussion about having two different names for what is now both called `mut`:


  #grid(columns: (1fr, 1fr), column-gutter: 1em)[
    #pause
    *Re-assignment `mut`*

    ```rust
    let mut a = 1;
    a = 2; // You can re-assign the variable

    impl {
      fn some_method(mut self) {
        // You can re-assign to self.
        self = some_thing(); // not very useful
        self.field = 2; // may be useful
      }
    }
    ```
  ][
    #pause
    *Pointer `mut`*

    ```rust
    let mut a = 1;
    let b = &mut a; // Need assignment `mut` on `a`
    *b = 2; // You can assign through the pointer
    ```
  ]

  Both are related to mutability, but are completely separate.
]

== Slices

#slide[

  #info[
    A slice is a *view* into a contiguous sequence. (Like a horizontal continuous window)
  ]

  ```rust
  fn main() {
      let a: [i32; 6] = [10, 20, 30, 40, 50, 60];
      println!("a: {a:?}");
      let s: &[i32] = &a[2..4];
      println!("s: {s:?}");
  }
  ```

  #pause

  #qa[Can we drop the end index in the slice?][Yes, it defaults to the length of the array.]


]


#slide[


  #fletcher-diagram(
    spacing: (3.5em, 2em),
    node((3, 0.5), stroke: blue, [Array `[T; N]`], name: <array>),
    node((3, 1), [Element `10`], name: <elem0>),
    node((3, 2), [Element `20`], name: <elem1>),
    node((3, 3), [Element `30`], name: <elem2>),
    node((3, 4), [Element `40`], name: <elem3>),
    edge(<elem2>, <elem3>, ".."),
    node(enclose: (<elem0>, <elem1>, <elem2>, <elem3>), stroke: blue, name: <array_elems>),
    pause,
    node((0, 1), stroke: red, [Slice], name: <slice>),
    edge(<slice_elem0>, <elem2>, "->"),
    node((0, 2), [Element `30`], name: <slice_elem0>),
    edge(<slice_elem1>, <elem3>, "->"),
    node((0, 3), [Element `40`], name: <slice_elem1>),
    edge(<slice_elem0>, <slice_elem1>, ".."),
    node((0, 4), [Length info \ omitted], name: <slice_elems>),
    node(enclose: (<slice_elem0>, <slice_elem1>), stroke: red, name: <slice_elems>),
    // An algorithm on the left goes through the slice in the middle to the array on the right

    pause,
    edge(<process0>, <slice_elems>, "->"),
    node((-2, 2.5), [Your \ code], name: <process0>),
  )

  #qa[What happens when you have the slice, but destroy the original array?][Not possible in normal Rust. (See later about lifetimes)]
]

#slide[

  More limitations of slices:

  - You cannot append elements to a slice.
  - You cannot grow a slice.
  - You cannot shrink a slice.


  However, slices have unique functionality defined.

  #warning[
    Data carriers like arrays may refer you to the methods of the associated slices.]

  (see next slides about strings)

]

== Strings

#slide[
  #set text(0.9em)
  #grid(columns: 2, column-gutter: 0.5em)[
    ```rust
    fn main() {
        let s1: &str = "World";
        println!("s1: {s1}");

        let mut s2: String = String::from("Hello ");
        println!("s2: {s2}");

        s2.push_str(s1);
        println!("s2: {s2}");

        let s3: &str = &s2[2..9];
        println!("s3: {s3}");
    }
    ```][

    Two new types:

    - A `&str` is an immutable slice of a `String`.
    - A `String` is mutable vector of UTF-8 characters.


    For the C++ programmers:

    - `&str` is like `std::string_view`
    - `String` is like `std::string`

    Usage:

    - `String::from(&str)` creates a `String` from a `&str`.
    - `&String` coerces to `&str` automatically.
    - String interpolation with formatting macros: `println!`, `format!`, `dbg!`, etc.
  ]
]

#slide[
  #fletcher-diagram(
    spacing: (3.5em, 1.5em),
    node((3, 0.0), stroke: blue, [mutable `String`], name: <string>),
    node((3, 1), [Character `H`], name: <char0>),
    node((3, 2), [Character `e`], name: <char1>),
    node((3, 3), [Character `l`], name: <char2>),
    node((3, 4), [Character `l`], name: <char3>),
    node((3, 5), [Character `o`], name: <char4>),
    edge(<char2>, <char3>, ".."),
    node(enclose: (<char0>, <char1>, <char2>, <char3>, <char4>), stroke: blue, name: <string_chars>),
    pause,
    node((4, 3), [Heap], name: <heap>),
    node(enclose: (<string_chars>, <string>, <heap>), stroke: purple),
    pause,
    node((0, 1), stroke: red, [String slice `&str` \ (immutable)], name: <slice>),
    edge(<slice_elem0>, <char2>, "->"),
    node((0, 2), [Character `l`], name: <slice_elem0>),
    edge(<slice_elem1>, <char3>, "->"),
    node((0, 3), [Character `l`], name: <slice_elem1>),
    edge(<slice_elem0>, <slice_elem1>, ".."),
    node((0, 4), [Length info \ omitted], name: <slice_elems>),
    node(enclose: (<slice_elem0>, <slice_elem1>), stroke: red, name: <slice_elems>),
  )
]


#slide[
  #qa[Is it possible to have a mutable string slice (`&mut str`)?][No.]

  #pause

  #qa[Why can't we have `&mut str`?][Because strings are UTF-8 encoded and modifying individual bytes could create invalid UTF-8. Use `String` for mutation or `&mut [u8]` for byte manipulation.]

  #pause

  #qa[When should you use `String` vs `&str` in function parameters?][Prefer `&str` for parameters (more flexible - accepts both `String` and `&str`). Use `String` when you need ownership or will modify it.]

]



#slide[

  #qa[What if you *don't want UTF-8* encoding?,][Youuse byte slices of type `&[u8]`:]

  ```rust
  println!("{:?}", b"abc");
  println!("{:?}", &[97, 98, 99]);
  ```

  Are you going "inception", use '\\' escapes (or a special Rust feature '\#'):

  ```rust
  println!(r#"<a href="link.html">link</a>"#);
  println!("<a href=\"link.html\">link</a>");
  ```

]

== Reference validity

#slide[


  ```rust
  fn main() {
      let x_ref = {
          let x = 10;
          &x
      };
      dbg!(x_ref);
  }
  ```

  #pause

  #qa[References in Rust are always safe to use, why?][
    - references can never be null
    - references can't outlive the data they point to
  ]

  (See next lectures)
]

== Exercise: vectors



#slide[
  #set text(0.7em)

  === Task

  #link("https://google.github.io/comprehensive-rust/references/exercise.html")

  #qrcode("https://google.github.io/comprehensive-rust/references/exercise.html")

  Calculate the magnitude of a vector. Use the `sqrt()` method to calculate the square root, like `v.sqrt()`.



  ```rust
    fn magnitude(...) -> f64 { todo!() }
  ```
  Normalize a vector by calculating its magnitude and dividing all of its coordinates by that magnitude.
  ```rs
    fn normalize(...) { todo!() }
  ```
  Use the following `main` to test your work.
  ```rs
  fn main() {
      println!("Magnitude of a unit vector: {}", magnitude(&[0.0, 1.0, 0.0]));

      let mut v = [1.0, 2.0, 9.0];
      println!("Magnitude of {v:?}: {}", magnitude(&v));
      normalize(&mut v);
      println!("Magnitude of {v:?} after normalization: {}", magnitude(&v));
  }
  ```
]



#slide(composer: (1fr, 1fr))[
  === Solution

  #set text(0.7em)

  ```rust
  fn magnitude(vector: &[f64; 3]) -> f64 {
      let mut mag_squared = 0.0;
      for coord in vector {
          mag_squared += coord * coord;
      }
      mag_squared.sqrt()
  }

  fn normalize(vector: &mut [f64; 3]) {
      let mag = magnitude(vector);
      for item in vector {
          *item /= mag;
      }
  }
  ```
][
  #set text(0.7em)

  ```rs
    fn main() {
        println!("Magnitude of a unit vector: {}", magnitude(&[0.0, 1.0, 0.0]));
        let mut v = [1.0, 2.0, 9.0];
        println!("Magnitude of {v:?}: {}", magnitude(&v));
        normalize(&mut v);
        println!("Magnitude of {v:?} after normalization: {}", magnitude(&v));
    }
  ```



  #qa[Why can we write `*item /= mag`?][`vector` is a mutable slice and `for` generates mutable references to its elements.]

  #pause

  #qa[What would be the issue when we drop the length `3`?][Runtime length check.]
]

== Exercise: Type conversions

#slide[
  #set text(0.85em)

  #grid(columns: (1fr, 1fr), column-gutter: 1em)[

    Write a function that converts temperatures between Celsius and Fahrenheit.

    ```rust
    fn celsius_to_fahrenheit(c: f64) -> f64 {
        todo!()
    }

    fn fahrenheit_to_celsius(f: f64) -> f64 {
        todo!()
    }
    ```

    Formula: $F = C times 9/5 + 32$
  ][
    Test it:
    ```rust
    fn main() {
        let freezing_c = 0.0;
        let boiling_c = 100.0;

        println!("{freezing_c}°C = {:.1}°F", celsius_to_fahrenheit(freezing_c));

    }
    ```

    Expected output: `0°C = 32.0°F`, `100°C = 212.0°F`, `98.6°F = 37.0°C`]
]

== Exercise: String manipulation

#slide(composer: (1fr, 1fr))[
  === Assignment
  #set text(0.85em)

  Write a function that counts vowels in a string.

  ```rust
  fn count_vowels(text: &str) -> usize {
      todo!()
  }
  ```

  Hints:
  - Use `text.chars()` to iterate over characters
  - Use `matches!` macro or `if` to check vowels: `'a', 'e', 'i', 'o', 'u'`
  - Remember to handle both uppercase and lowercase
][#set text(0.85em)

  Test it:
  ```rust
  fn main() {
      assert_eq!(count_vowels("hello"), 2);
      assert_eq!(count_vowels("Rust Programming"), 4);
      assert_eq!(count_vowels("rhythm"), 0);
  }
  ```
]

