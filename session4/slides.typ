
#import "../template/lib.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 4: Lifetimes],
    subtitle: [Practice smart pointers and lifetimes],
    author: [Willem Vanhulle],
    date: [Tuesday November 25, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  enable-qr-codes: false,
)

#title-slide()

== Educational videos

For the people who are interested in `dyn`, `dyn` is an example of a dynamically-sized-type or `unsized` / `!Sized` type. Read more about such types in https://github.com/pretzelhammer/rust-blog/blob/master/posts/sizedness-in-rust.md

#warning[If forgot to mention that `dyn` trait objects are a kind of type erasure. They erase size, alignment and other compile-time properties of the concrete types.]


Youtubers that makes good videos about Rust:
- Jon Gjengset: https://www.youtube.com/c/JonGjengset
- Tris https://www.youtube.com/@NoBoilerplate

#focus-slide[
  Jon Gjengset makes Youtube videos
  #image("images/jon.jpg", height: 70%)
]


= Smart pointers

== Review test

#qa[What is a smart pointer?][A pointer with ownership.]

#qa[Name 10 smart pointers in Rust.][
  `Box<T>`, `Rc<T>`, `Arc<T>`, `RefCell<T>`, `Mutex<T>`, `RwLock<T>`, `Weak<T>`, `Cow<T>`, `String`, `Vec<T>`.
]

A pointer is generally speaking a type that implements `Deref` trait.

```rs
pub trait Deref {
    type Target: ?Sized;
    fn deref(&self) -> &Self::Target;
}
```

#qa[Which types implement `Deref` but are NOT smart pointers?][
  References (`&T`, `&mut T`) are primitive pointers without ownership. `Cell<T>` and `MaybeUninit<T>` don't implement `Deref`.
]


== Visualisation

#slide[
  #set align(center + horizon)

  #fletcher-diagram(
    node((0, 0), name: <data>, shape: shapes.circle, stroke: black, [Data]),
    node((0, 1), name: <owner>, [Smart pointer \ (owner)], stroke: black),

    node((-1, 0), name: <left>),
    node((1, 0), name: <right>),
    edge(<owner>, <left>, bend: 45deg, "-->"),
    edge(<owner>, <right>, bend: -45deg, "-->"),
    edge(<owner>, <data>, "->"),
  )
]

== Exercises


Solve the exercises in `session4/examples/` (if you haven't already) in 30 minutes.

Are you done or bored? Implement your own smart pointer. It should own its data and provide shared access to it (single threaded):

- Use `dealloc` and `alloc` for unsafe memory management
- Use `AtomicUsize` for reference counting

Solution in `main.rs` (don't read before trying)

= Lifetimes (new)

== Borrowing with functions

```rust
fn borrows(x: &i32) {
    dbg!(x);
}

fn main() {
    let mut val = 123;

    // Borrow `val` for the function call.
    borrows(&val);

    // Borrow has ended and we're free to mutate.
    val += 5;
}
```

== Returning Borrows

```rust
fn identity(x: &i32) -> &i32 {
    x
}

fn main() {
    let mut x = 123;
    let out = identity(&x);
    // x = 5; // 🛠️❌ `x` is still borrowed!
    dbg!(out);
}
```

#qa[How does the compiler check `out` is not a dangling reference?][By checking the lifetimes of the references.]

#qa[Where are the lifetimes?][They are hidden in the signature (*lifetime elision*).]

== Multiple Borrows

```rs
fn multiple(a: &i32, b: &i32) -> &i32 {
    todo!("Return either `a` or `b`")
}

fn main() {
    let mut a = 5; let mut b = 10;
    let r = multiple(&a, &b);

    // Which one is still borrowed?
    // Should either mutation be allowed?
    a += 7; b += 7;
    dbg!(r);
}
```

#qa[Why does this code not compile?][Compiler cannot derive which reference to return, so both are considered borrowed.]

== Borrow both



```rs
fn pick<'a>(c: bool, a: &'a i32, b: &'a i32) -> &'a i32 {
    if c { a } else { b }
}

fn main() {
    let mut a = 5; let mut b = 10;
    let r = pick(true, &a, &b);
    // Which one is still borrowed?
    // Should either mutation be allowed?
    // a += 7;
    // b += 7;
    dbg!(r);
}
```

#qa[Which argument is borrowed?][Both `a` and `b` are borrowed for the lifetime of `r`. Compiler looks only at signature.]

#focus-slide[
  Don't borrow from independent owners
  #box[

    #image("images/cheat.jpg", height: 6em)
    #set text(fill: green.darken(40%))
    #place(dx: 1em, dy: -1em)[`'a`]
    #place(dx: 6em, dy: -4em)[`'b`]
  ]
]

== Borrow One

It is possible to borrow from only one argument by introducing a second lifetime. (Even why they are both references)

Open example file for demonstration: `find-nearest.rs`

== Lifetime Elision

#slide[
  ```rs
  fn only_args(a: &i32, b: &i32) {
      todo!();
  }

  fn identity(a: &i32) -> &i32 {
      a
  }

  struct Foo(i32);
  impl Foo {
      fn get(&self, other: &i32) -> &i32 {
          &self.0
      }
  }
  ```

][
  #pause

  === Rules for lifetime elision

  ... for references in argument or return position:

  - Each argument which does not have a lifetime annotation is given one.
  - If there is only *one argument lifetime*, it is given to all un-annotated return values.
  - If there are *multiple argument lifetimes*, but the *first one is for self*, that lifetime is given to all un-annotated return values.

  #pause
  #warning[Lifetime elision rules are tricky and very important! Learn them by heart!]

  #pause

  Complete elided lifetimes in the example code in example file `lifetime-elision.rs`.

]


== Lifetimes in Data Structures

#slide[
  #set text(size: 0.7em)
  ```rs
  #[derive(Debug)]
  enum HighlightColor {
      Pink,
      Yellow,
  }

  #[derive(Debug)]
  struct Highlight<'document> {
      slice: &'document str,
      color: HighlightColor,
  }

  fn main() {
      let doc = String::from("The quick brown fox jumps over the lazy dog.");
      let noun = Highlight { slice: &doc[16..19], color: HighlightColor::Yellow };
      let verb = Highlight { slice: &doc[20..25], color: HighlightColor::Pink };
      // drop(doc);
      dbg!(noun);
      dbg!(verb);
  }
  ```

  #qa[What does the lifetime `'document` represent?][The lifetime of the slice referring to `doc` String in `main()` needs to exceed any instance of `Highlight` (that contains that slice).]

]


== Guidelines


- Types with borrowed data *force users to hold on to the original* data. This can be performant (but harder):
  - creating lightweight views
  - allocation-free parsers
- When possible, make data structures own their data directly.

#focus-slide[
  Don't develop attachment issues with lifetimes
  #image("images/attach.jpg", height: 70%)
]


== Exercises:

- introductory exercises in Rustlings chapter 16: Lifetimes (clone the Rustlings repo)
- advanced exercise in example file `protobuf-parsing.rs`. (in this session's examples folder)


== More reading material

For those interested: read this #link("https://github.com/pretzelhammer/rust-blog/blob/master/posts/common-rust-lifetime-misconceptions.md#10-closures-follow-the-same-lifetime-elision-rules-as-functions")[Blog post by PretzelHammer titled "Common Rust Lifetime Misconceptions"]


== Quiz







#qa[
  It is possible to write large Rust programs without ever using lifetimes. True or false?
][
  Not quite true. Lifetimes are almost always omitted because of lifetime elision rules. You need them for implementing iterators.

]


== Demonstration

#slide[
  #set text(size: 0.8em)

  ```rs
  struct ByteIter<'a> {
      remainder: &'a [u8]
  }

  impl<'a> ByteIter<'a> {
      fn next(&mut self) -> Option<&u8> {
          if self.remainder.is_empty() {
              None
          } else {
              let byte = &self.remainder[0];
              self.remainder = &self.remainder[1..];
              Some(byte)
          }
      }
  }

  fn main() {
      let mut bytes = ByteIter { remainder: b"1" };
      assert_eq!(Some(&b'1'), bytes.next());
      assert_eq!(None, bytes.next());
  }
  ```
]



#slide[
  #set text(size: 0.8em)
  ```rs
  fn main() {
      let mut bytes = ByteIter { remainder: b"1123" };
      let byte_1 = bytes.next();
      let byte_2 = bytes.next();
      if byte_1 == byte_2
          // do something
      }
  }
  ```
  #qa[Will it compile?][No.]
  ```
  error[E0499]: cannot borrow `bytes` as mutable more than once at a time
    --> src/main.rs:20:18
     |
  19 |     let byte_1 = bytes.next();
     |                  ----- first mutable borrow occurs here
  20 |     let byte_2 = bytes.next();
     |                  ^^^^^ second mutable borrow occurs here
  21 |     if byte_1 == byte_2 {
     |        ------ first borrow later used here
  ```]

#slide[
  Fill in missing lifetimes and name them properly

  #codly(
    highlights: (
      (line: 6, start: 55, end: 64, fill: red),
    ),
  )
  ```rs
  struct ByteIter<'remainder> {
      remainder: &'remainder [u8]
  }

  impl<'remainder> ByteIter<'remainder> {
      fn next<'mut_self>(&'mut_self mut self) -> Option<&'mut_self u8> {
          if self.remainder.is_empty() {
              None
          } else {
              let byte = &self.remainder[0];
              self.remainder = &self.remainder[1..];
              Some(byte)
          }
      }
  }
  ```
]

== Lifetime bounds


#slide[

  ```rs
  struct Wrapper<T> {
      value: T,
  }
  ```

  #qa[Wherever the type generic `T` appears only owned types may be used. True or false?][False. `T` may contain references too.]


  #pause
  #fletcher-diagram(
    node((0, 0), [Outer world]),


    node(
      enclose: (<var>, <ref>),
      name: <scope>,
      stroke: red,
      inset: 1em,
    ),

    node(
      (0, 2),
      [Generic type `T`],
      name: <generic>,
    ),
    edge(<generic>, <scope>, "-->"),
    node((2, 1), [Variable `c`], name: <var-out>, stroke: blue),

    pause,
    node((-1, 1), [Variable `a`], name: <var>, stroke: green),

    node((1, 1), [Reference `b = &c`], name: <ref>, stroke: blue),

    edge(<ref>, <var-out>, "->"),

    pause,
    node((1, 2), [`T` contains lifetime \ (to the outside)], name: <lifetime>),
    edge(<lifetime>, <ref>, "-->"),
  )

  In this situation: `T: 'out` where `'out` is the lifetime of `b` (may be implicit in `T`)
]

#slide[
  Type compatibility for generic type parameters:
  #table(
    columns: 4,
    stroke: 0.5pt,
    [*Type Variable*], [`T`], [`&T`], [`&mut T`],
    [*Examples*],
    [`i32`, `&i32`, `&mut i32`, `&&i32`, ...],
    [`&i32`, `&&i32`, `&&mut i32`, ...],
    [`&mut i32`, `&mut &mut i32`, `&mut &i32`, ...],
  )



  ```rust
  trait Trait {}
  impl<T> Trait for T {}
  impl<T> Trait for &T {} // ❌
  impl<T> Trait for &mut T {} // ❌
  ```

  #qa[Why do the last two `impl` blocks not compile?][The compiler doesn't allow us to define an implementation of `Trait` for `&T` and `&mut T` since it would conflict with the implementation of `Trait` for `T` which already includes all of `&T` and `&mut T`]
]



== `'static` lifetime

The `'static` is a special lifetime (not to be confused with the `'static` keyword for variables). It stands for the longest / maximum lifetime.

#qa[
  If `T: 'static` then T must be valid for the entire program. True or false?

][
  False. `T: 'static` means that `T` does *not contain any non-'static references*. It may only contain `'static` references or no references at all.
]
#pause

Examples: primitive types: `i32`, `f64`, `bool`, `char`.

Conclusion:

- `T: 'static` should be read as _"`T` can live at least as long as a `'static` lifetime"_ #pause
- if `T: 'static` then `T` can be a borrowed type with a `'static` lifetime _or_ an owned type #pause
- since `T: 'static` includes owned types that means `T`
  - can be dynamically allocated at run-time
  - does not have to be valid for the entire program
  - can be safely and freely mutated
  - can be dynamically dropped at run-time
  - can have lifetimes of different durations



#focus-slide[
  `T: 'static` and `impl Trait + 'static`
  #image("images/house.jpg", height: 70%)
]

#focus-slide[
  `const INFO: &'static str = "I live for the entire program!"`;
  #image("../session3/images/drill.png", height: 70%)
]

#focus-slide[
  `static ARRAY: [i32; 3] = [1, 2, 3];`
  #image("../session3/images/foundation.jpg", height: 70%)

]

== Recent change in compiler

Since 2025 (Rust edition 2024), `impl` blocks in the return type position now capture lifetimes in argument position automatically.

```rs
fn multiply_adapter(
    iter: impl Iterator<Item = i32>,
    factor: &Wrapper,
) -> impl Iterator<Item = i32> {
    iter.map(move |x| x * factor.factor)
}
```

See example `impl-return.rs` for demonstration.

= Iterators

== Motivation

If you want to iterate over the contents of an array, you’ll need to define:

- Some state to keep track of where you are in the iteration process, e.g. an index.
- A condition to determine when iteration is done.
- Logic for updating the state of iteration each loop.
- Logic for fetching each element using that iteration state.

```c
for (int i = 0; i < array_len; i += 1) {
    int elem = array[i];
}
```

#pause

#qa[What is the closest C equivalent of this to Rust?][It uses a pointer that is incremented instead of an index.]

```c
for (int *ptr = array; ptr < array + len; ptr += 1) {
    int elem = *ptr;
}
```

== Iterator trait

#slide[
  #set text(size: 0.7em)


  ```rs
  struct SliceIter<'s> {
      slice: &'s [i32],
      i: usize,
  }

  impl<'s> Iterator for SliceIter<'s> {
      type Item = &'s i32;

      fn next(&mut self) -> Option<Self::Item> {
          if self.i == self.slice.len() {
              None
          } else {
              let next = &self.slice[self.i];
              self.i += 1;
              Some(next)
          }
      }
  }


  ```
][
  #set align(horizon)

  The Iterator trait defines how an object can be used to *produce a sequence of values*.
  ```rs
     fn main() {
      let slice = &[2, 4, 6, 8];
      let iter = SliceIter { slice, i: 0 };
      for elem in iter {
          dbg!(elem);
      }
  }
  ```
]


#pagebreak()

#qa[Why are Rust iterators lazy?][You can call `next()` to get the next element only when you need it.]

#qa[What happens when you call `next()` after the iterator returned `None`][We don't know. Only fused iterators guarantee `None` forever after.]

```rs
fn main() {
    let mut iter = SliceIter { slice: &[1, 2], i: 0 };
    assert_eq!(Some(&1), iter.next());
    assert_eq!(Some(&2), iter.next());
    assert_eq!(None, iter.next());
    assert_eq!(??? , iter.next()); // What happens here?
}
```




== Generators


#qa[Give an example of an infinite iterator.][The range `0..` is an infinite iterator of integers starting from 0.]

Iterators can also be generated with coroutines (called generators in Rust):

```rs
fn counter() -> impl Iterator<Item = i32> {
    gen {
        let mut count = 0;
        loop {
            yield count;
            count += 1;
        }
    }
}
```
(Also an infinite iterator)



== Helpers

the Iterator trait provides *helper methods* that can be used to transform iterators:

```rs
fn main() {
    let result: i32 = (1..=10) // Create a range from 1 to 10
        .filter(|x| x % 2 == 0) // Keep only even numbers
        .map(|x| x * x) // Square each number
        .sum(); // Sum up all the squared numbers

    println!("The sum of squares of even numbers from 1 to 10 is: {}", result);
}
```


#qa[What is another name for iterator helpers?][Adapters (or operators or combinators).]

#qa[How many adapters are there in the standard library?][Approximately 40.]


== Collect

Build collections from iterators:

```rust
fn main() {
    let primes = vec![2, 3, 5, 7];
    let prime_squares = primes.into_iter().map(|p| p * p).collect::<Vec<_>>();
    println!("prime_squares: {prime_squares:?}");
}
```

#qa[What are the collections that we can collect into?][Vectors, HashMaps, HashSets, BtreeMap, BtreeSet, VecDeque, ... (your own collections too!)]

Target collection type is either implicit or specified with:

#pause

- Turbofishing: `collect::<Vec<_>>()`
- Type annotation: `let v: Vec<_> = iterator.collect();`

== Consuming adapters

Consume the iterator and produce a final value:

```rs
let nums = vec![1, 2, 3, 4, 5];
nums.iter().collect::<Vec<_>>();  // collect into collection
nums.iter().sum::<i32>();          // reduce to single value
nums.iter().count();               // count elements
nums.iter().fold(0, |acc, x| acc + x); // general reduction
nums.iter().for_each(|x| println!("{}", x)); // side effects
```

Other examples: `max`, `min`, `find`, `any`, `all`, `partition`, `reduce`.

#qa[Why are they called "consuming"?][They call `next()` until `None`.]

== Nonconsuming adapters

Transform an iterator into another iterator (lazy):

```rs
let nums = vec![1, 2, 3, 4, 5];
nums.iter().map(|x| x * 2);        // transform elements
nums.iter().filter(|x| *x % 2 == 0); // keep matching elements
nums.iter().take(3);               // limit to first N
nums.iter().skip(2);               // skip first N
nums.iter().enumerate();           // add indices
nums.iter().chain([6, 7].iter());  // concatenate
nums.iter().zip(['a', 'b'].iter()); // pair up
```

Other examples: `flatten`, `flat_map`, `peekable`, `rev`, `cycle`, `cloned`.

#qa[Why are they called "nonconsuming"?][They don't run until a consuming adapter is called.]

== Overhead

#qa[What is the cost of using lots of iterator adapters?][There is no runtime overhead because most adapters work by reference and can be inlined or optimized by the compiler.]

Exercises: Rustlings, chapter 18: Iterators

== `AsyncIterator` adapters

#slide[
  #set text(size: 0.9em)

  Fragment from #link("https://github.com/wvhulle/streams-eurorust-2025")[my EuroRust 2025 talk on functional async programming in Rust (github.com/wvhulle/streams-eurorust-2025/)]:

  #grid(
    columns: (1fr, 0.4fr),
    column-gutter: 1em,
    ```rust
    let results: Vec<String> = tcp_stream
        .filter_map(|conn| ready(conn.ok()))
        .filter(|stream| ready(should_process(stream)))
        .then(|stream| process_stream(stream))
        .filter_map(|result| ready(result.ok()))
        .filter(|msg| ready(msg.len() > 10))
        .take(5)
        .collect()
        .await;
    ```,
    align(horizon)[
      *Benefits:*
      - Each operation is isolated
      - Testable
      - Reusable
    ],
  )


]


== IntoIterator

IntoIterator defines how to create an iterator for a type:

```rs
struct Grid {
    x_coords: Vec<u32>,
    y_coords: Vec<u32>,
}

impl IntoIterator for Grid {
    type Item = (u32, u32);
    type IntoIter = GridIter;
    fn into_iter(self) -> GridIter {
        GridIter { grid: self, i: 0, j: 0 }
    }
}
```


== The "actual" / physical iterator

#slide[
  #set text(size: 0.8em)
  ```rs
  struct GridIter {
      grid: Grid,
      i: usize,
      j: usize,
  }

  impl Iterator for GridIter {
      type Item = (u32, u32);

      fn next(&mut self) -> Option<(u32, u32)> {
          if self.i >= self.grid.x_coords.len() {
              self.i = 0;
              self.j += 1;
              if self.j >= self.grid.y_coords.len() {
                  return None;
              }
          }
          let res = Some((self.grid.x_coords[self.i], self.grid.y_coords[self.j]));
          self.i += 1;
          res
      }
  }
  ```
]
== Different `IntoIterator` implementations

Iterating over a vector like this will consume it:

```rs
let v = vec![1, 2, 3];
for elem in v {
    dbg!(elem);
}
// v is no longer usable here
```

Iterating over a reference to a vector will not consume it:

```rs
let v = vec![1, 2, 3];
for elem in &v {
    dbg!(elem);
}
// v is still usable here
```

== Iterate over Grid by reference

#slide[
  #set text(size: 0.8em)
  You might have multiple ways to create an iterator for a type.

  Usually, by value (consuming) or by reference (non-consuming):

  ```rs
  impl<'a> IntoIterator for &'a Grid {
      type Item = (u32, u32);
      type IntoIter = GridRefIter<'a>;
      fn into_iter(self) -> GridRefIter<'a> {
          GridRefIter { grid: self, i: 0, j: 0 }
      }
  }
  ```
  From a mutable reference (non-consuming + mutable):

  ```rs
  impl<'a> IntoIterator for &'a mut Grid {
      type Item = (u32, u32);
      type IntoIter = GridMutRefIter<'a>;
      fn into_iter(self) -> GridMutRefIter<'a> {
          GridMutRefIter { grid: self, i: 0, j: 0 }
      }
  }
  ```

  See example file `into-iterator-ref.rs`.
]


== Exercises

Solve the exercise in `tests/iterator-method-chaining.rs`


Create your own iterator by implementing `Iterator` and `IntoIterator` in `examples/custom-iterator.rs`


Build your own `Iterator` adapters in `examples/iterator-adapters.rs`

