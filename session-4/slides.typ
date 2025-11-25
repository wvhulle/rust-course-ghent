
#import "../template.typ": *



#show: rust-course.with(
  config-info(
    title: [Lecture 4: Lifetimes],
    subtitle: [Practice smart pointers and lifetimes],
    author: [Willem Vanhulle],
    date: [Tuesday November 25, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)

#title-slide()

= Smart pointers (practice)

== Recap

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
#pagebreak()

A smart pointer is a reference / pointer that also owns the data it points to:

#fletcher-diagram(
  node((0, 0), name: <data>, shape: shapes.circle, stroke: black, [Data]),
  node((0, 1), name: <owner>, [Smart pointer \ (owner)], stroke: black),

  node((-1, 0), name: <left>),
  node((1, 0), name: <right>),
  edge(<owner>, <left>, bend: 45deg, "-->"),
  edge(<owner>, <right>, bend: -45deg, "-->"),
  edge(<owner>, <data>, "->"),
)

Solve the exercises in `session-4/examples/` (if you haven't already) in 30 minutes.

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

== Borrow One

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

  #qa[Try to complete the missing lifetimes manually in the example code.][See example file `lifetime-elision.rs`]
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

  #qa[What does the lifetime `'document` represent?][The lifetime of the slice refering to `doc` String in `main()` needs to exceed any instance of `Highlight` (that contains that slice).]

]


== Guidelines


- Types with borrowed data *force users to hold on to the original* data. This can be performant (but harder):
  - creating lightweight views
  - allocation-free parsers
- When possible, make data structures own their data directly.


#pause

Exercises:

- introductory exercises in Rustlings chapter 16: Lifetimes (clone the Rustlings repo)
- advanced exercise in example file `protobuf-parsing.rs`. (in this session's examples folder)


== More reading material

For those interested: read this #link("https://github.com/pretzelhammer/rust-blog/blob/master/posts/common-rust-lifetime-misconceptions.md#10-closures-follow-the-same-lifetime-elision-rules-as-functions")[Blog post by PretzelHamer titled "Common Rust Lifetime Misconceptions"]

Examples of misconceptions (*wrong*):

- T only contains owned types
- if `T: 'static` then T must be valid for the entire program
- `&'a T` and `T: 'a` are the same thing
- my code isn't generic and doesn't have lifetimes
- if it compiles then my lifetime annotations are correct

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

#qa[What is the closest C equivalent of this to Rust?][It uses a pointer that is incremented instead of an index.]

```c
for (int *ptr = array; ptr < array + len; ptr += 1) {
    int elem = *ptr;
}
```

== Iterator trait

#slide[
  #set text(size: 0.6em)

  The Iterator trait defines how an object can be used to *produce a sequence of values*. For example,

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

  fn main() {
      let slice = &[2, 4, 6, 8];
      let iter = SliceIter { slice, i: 0 };
      for elem in iter {
          dbg!(elem);
      }
  }
  ```
]


== Questions

#qa[Why are Rust iterators lazy?][You can call `next()` to get the next element only when you need it.]


#qa[Give an example of an infinite iterator.][`std::iter::repeat(value)` produces an infinite sequence of `value`.]


== Helpers

the Iterator trait provides helper methods that can be used to build customized iterators:

```rs
fn main() {
    let result: i32 = (1..=10) // Create a range from 1 to 10
        .filter(|x| x % 2 == 0) // Keep only even numbers
        .map(|x| x * x) // Square each number
        .sum(); // Sum up all the squared numbers

    println!("The sum of squares of even numbers from 1 to 10 is: {}", result);
}
```

#qa[What is another name for iterator helpers?][Adapters.]

#qa[How many adapters are there in the standard library?][Approximately 40.]
