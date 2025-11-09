#import "../template.typ": *

= Generics

== Generic functions

```rs
fn pick<T>(cond: bool, left: T, right: T) -> T {
    if cond { left } else { right }
}

fn main() {
    println!("picked a number: {:?}", pick(true, 222, 333));
    println!("picked a string: {:?}", pick(false, 'L', 'R'));
}
```

Bodies of generic functions need to be well-defined for all possible types T.

== Monomorphisation

The compiler *generates concrete versions* of generic functions for each used type.

```rs
fn pick_i32(cond: bool, left: i32, right: i32) -> i32 {
    if cond { left } else { right }
}

fn pick_char(cond: bool, left: char, right: char) -> char {
    if cond { left } else { right }
}
```

Generics are a zero-cost abstraction.

#focus-slide[
  #image("images/constraint.jpg", width: 100%)
]

== Trait bounds

Require the types to implement some trait, so that you can call this trait's methods

```rs
fn duplicate<T: Clone>(a: T) -> (T, T) {
    (a.clone(), a.clone())
}

struct NotCloneable;

fn main() {
    let foo = String::from("foo");
    let pair = duplicate(foo);
    println!("{pair:?}");
}
```

#qa[What happens if we pass `NotCloneable` to duplicate? (Try in playground!)][A compile-time error, because `NotCloneable` does not implement the Clone trait.]


== Combining traits

When multiple traits are necessary, use + to join them.

```rs
fn compare_and_print<T: PartialOrd + Display>(a: T, b: T) {
    if a < b {
        println!("{} is less than {}", a, b);
    } else {
        println!("{} is not less than {}", a, b);
    }
}
```

== Composition over inheritance

#slide[

  *Rust forbids object inheritance completely.*

  #grid(columns: (1fr, 1fr), column-gutter: 3em)[

    #fletcher-diagram(
      node((0, -1.5), [*Class inheritance*]),
      node((0, 0), [Parent Class], name: <parent>, fill: red.lighten(70%)),
      node((0, 2), [Child Class], name: <child>, fill: red.lighten(70%)),
      edge(<child>, <parent>, "->", label: "inherits"),
      pause,
      node((-1, 1), [fields], name: <fields>),
      node((1, 1), [methods], name: <methods>),
      edge(<fields>, <parent>, "..>"),
      edge(<methods>, <parent>, "..>"),
      edge(<fields>, <child>, "..>"),
      edge(<methods>, <child>, "..>"),

      pause,
      node((0, -1), [Parent parent Class], name: <parent-parent>, fill: red.lighten(70%)),
      edge(<parent>, <parent-parent>, "->", label: "inherits", stroke: red),
      edge(<fields>, <parent-parent>, "..>", label: [overridable], stroke: red),
      edge(<methods>, <parent-parent>, "..>", label: [overridable], stroke: red),
    )
  ][
    #pause
    #fletcher-diagram(
      spacing: (0.8em, 3em),
      node((0, -2), [*Composition with traits*]),

      node((-1.5, -1.5), name: <div-left>),
      node((1.5, -1.5), name: <div-right>),
      edge(<div-left>, <div-right>, "="),
      node((0, 0), [Struct], name: <struct>, fill: green.lighten(70%)),
      node((-0.7, -1), [Trait A], name: <trait-a>, fill: orange.lighten(70%)),
      node((0.7, -1), [Trait B], name: <trait-b>, fill: orange.lighten(70%)),
      edge(<struct>, <trait-a>, "->", label: "impl"),
      edge(<struct>, <trait-b>, "->", label: "impl"),
      node((0, 1), [Field type], name: <other>, fill: blue.lighten(70%)),
      edge(<other>, <struct>, "->", label: "field"),
    )
  ]

  #pause


  #qa[Are traits in Rust a kind of multiple inheritance?][Yes, but no data inheritance. No diamond problem (see example `diamond-problem`).]
]

== `where` clauses

Declutters the function signature if you have many parameters

```rs
fn duplicate<T>(a: T) -> (T, T)
where
    T: Clone,
{
    (a.clone(), a.clone())
}
```

== Feature of `where` clauses

With `where` clauses you can put *trait bounds on composite types*:

```rs
fn duplicate_option<T>(a: Option<T>) -> (Option<T>, Option<T>)
where
  Option<T>: Clone,
{
  (a.clone(), a.clone())
}

fn main() {
  let s = Some(String::from("hello"));
  let pair = duplicate_option(s);
  println!("{pair:?}");
}
```

#info[Powerful feature of generic programming in Rust!]

== Generic datatypes

#slide[

  #set text(size: 0.7em)

  #grid(columns: (1fr, 1fr), column-gutter: 2em)[
    ```rs
    pub trait Logger {
        /// Log a message at the given verbosity level.
        fn log(&self, verbosity: u8, message: &str);
    }

    struct StderrLogger;

    impl Logger for StderrLogger {
        fn log(&self, verbosity: u8, message: &str) {
            eprintln!("verbosity={verbosity}: {message}");
        }
    }
    ```

    #pause


    You can implement a trait for a generic datatype *if you provide template type parameters*.

  ][
    Only log messages up to the given verbosity level:

    ```rs
    struct VerbosityFilter<L> {
        max_verbosity: u8,
        inner: L,
    }

    impl<L: Logger> Logger for VerbosityFilter<L> {
        fn log(&self, verbosity: u8, message: &str) {
            if verbosity <= self.max_verbosity {
                self.inner.log(verbosity, message);
            }
        }
    }
    ```

    #qa[Why is `L` specified twice in `impl<L: Logger>` .. `VerbosityFilter<L>`? Isn't that redundant?][`impl` parameters are separate and usually carries trait bounds (not the datatype).]

    #qa[What happens if you would just use a concrete type as in `impl VerbosityFilter<StderrLogger> { .. }`][Would only work with `StderrLogger` instances, not with any other type that implements `Logger`.]
  ]
]








#slide[
  #set text(size: 0.8em)
  === Blanket `impl` blocks

  A blanket implementation is an `impl` block that applies to *all types* that satisfy the trait bounds.

  #codly(
    highlights: (
      (line: 6, start: 5, end: 15, fill: red),
    ),
  )
  ```rs
  struct VerbosityFilter<L> {
      max_verbosity: u8,
      inner: L,
  }

  impl<L: Logger> Logger for VerbosityFilter<L> {
      fn log(&self, verbosity: u8, message: &str) {
          if verbosity <= self.max_verbosity {
              self.inner.log(verbosity, message);
          }
      }
  }
  ```

  It is a bit like in mathematics:

  $ forall l in "Logger": "VerbosityFilter"(l) -> "Logger"(l) $


]

=== Visualisation

#fletcher-diagram(
  node((0, -1), [*External\ libary*]),
  node(enclose: (<our-trait>, <method-1>, <method-2>), name: <trait-box>, fill: orange.lighten(90%)),
  node((0, 0), [External \ Trait], name: <our-trait>),

  pause,
  node(enclose: (<our-trait-2>, <method-3>, <method-4>), name: <our-trait-box-2>, fill: orange.lighten(90%)),
  node((-0.5, 1), [Method 1], name: <method-1>),
  node((0.5, 1), [Method 2], name: <method-2>),
  edge(<our-trait>, <method-1>, "->"),
  edge(<our-trait>, <method-2>, "->"),
  pause,


  node((1.5, -1.5), name: <div-up>),
  node((1.5, 2), name: <div-down>),
  edge(<div-up>, <div-down>, "="),
  node((2, -0.5), [Our \ Trait], name: <our-trait-2>),
  node((4, 1), [Our concrete \ type], name: <our-type>, fill: blue.lighten(70%)),

  pause,

  node((3, 0), [Additional \ method 3], name: <method-3>),
  edge(<our-trait-2>, <method-3>, "->"),
  node((3, -1), [Additional \ method 4], name: <method-4>),
  edge(<our-trait-2>, <method-4>, "->"),

  pause,

  node((2.5, 0.8), [Blanket \ impl], name: <blanket-impl>, fill: green.lighten(70%)),
  edge(<our-trait-2>, <blanket-impl>, "->"),
  edge(<blanket-impl>, <our-type>, "=>", label: [hooks up], bend: -15deg),
  edge(<trait-box>, <blanket-impl>, "->"),


  edge(<our-type>, <our-trait-box-2>, "->", label: [automatic]),
)

// #let tree = rule(
//   label: [Label],
//   name: [Rule name],
//   [Our type implements ],
//   [Premise 1],
//   [Premise 2],
//   [Premise 3],
// )

// $ prooftree(tree) $

#slide[
  === Putting constraints on super-traits (advanced)
  #set text(size: 0.8em)
  #grid(columns: (1fr, 1fr), column-gutter: 2em)[

    A subtrait can add constraints on the associated types of its supertrait.

    ```rs
    trait Container {
        type Item;
        fn get(&self) -> &Self::Item;
    }

    trait PrintableContainer: Container
    where
        Self::Item: Display,
    {
        fn print_item(&self) {
            println!("Item: {}", self.get());
        }
    }

    struct Box<T> {
        value: T,
    }
    ```
  ][
    ```rs
    impl<T> Container for Box<T> {
        type Item = T;
        fn get(&self) -> &Self::Item {
            &self.value
        }
    }

    impl<T: Display> PrintableContainer for Box<T> {}

    fn main() {
        let b = Box { value: 42 };
        b.print_item();
    }
    ```

    #qa[Why does `PrintableContainer` require `Self::Item: Display`?][It constrains the supertrait's associated type so that `print_item` can use the `Display` trait.]
  ]]




== Generic traits

The `From` trait is a standard library trait for type conversion.

```rs
pub trait From<T>: Sized {
    fn from(value: T) -> Self;
}

#[derive(Debug)]
struct Foo(String);
```

#info[Common traits in the standard library will be covered later on.]



#slide[
  #set text(size: 0.8em)
  === Example `From`

  ```rs
  impl From<u32> for Foo {
      fn from(from: u32) -> Foo {
          Foo(format!("Converted from integer: {from}"))
      }
  }

  impl From<bool> for Foo {
      fn from(from: bool) -> Foo {
          Foo(format!("Converted from bool: {from}"))
      }
  }
  fn main() {
      dbg!(Foo::from(123));
      dbg!(Foo::from(true));
  }
  ```

  #warning[Notice that a *generic trait can be implemented multiple times* for the same type!  ]
]

== Associated types vs. generic type parameters

It may not always be clear when to pick an associated type or a generic type.

#fletcher-diagram(
  spacing: (6em, 2em),
  node((0.5, -1), [*Associated types* \ (chosen by the implementer)]),
  node((0, 0), [Generic \ datatype], name: <type>, fill: green.lighten(70%)),
  node((1, 0), [Non-generic \ trait], name: <trait>, fill: orange.lighten(70%)),
  pause,
  node((0.5, 2), text(fill: blue)[Single, unique \ associated type], name: <assoc-type>),
  edge(<trait>, <assoc-type>, "->"),
  edge(<type>, <assoc-type>, "->"),

  node((1.5, -0.5), name: <div-up>),
  node((1.5, 2.5), name: <div-down>),
  edge(<div-up>, <div-down>, "="),
  pause,
  node((2.5, -1), [*Generic types parameters*\ (chosen by the caller)]),
  node((2.5, 0), [Generic\ datatype], name: <generic-data-type>, fill: green.lighten(70%)),
  node((2, 1), text(fill: blue)[Concrete type 1], name: <concrete-type-1>),
  node((3, 1), text(fill: blue)[Concrete type 2], name: <concrete-type-2>),
  edge(<generic-data-type>, <concrete-type-1>, "->"),
  edge(<generic-data-type>, <concrete-type-2>, "->"),
  node((2.5, 2.5), [Generic\ trait], name: <trait-assoc>, fill: orange.lighten(70%)),
  pause,
  node((2, 1.5), [`impl` block 1], name: <impl-block-1>),
  node((3, 1.5), [`impl` block 2], name: <impl-block-2>),

  edge(<concrete-type-1>, <impl-block-1>, "->"),
  edge(<concrete-type-2>, <impl-block-2>, "->"),
  edge(<impl-block-1>, <trait-assoc>, "->"),
  edge(<impl-block-2>, <trait-assoc>, "->"),
  pause,
  edge(<impl-block-1>, <impl-block-2>, "-/-", stroke: red, label: [May not \ overlap]),
)

- Associated types behave like output (first choice).
- Generic type parameters behave like input.

== Multiple generic `impl` blocks

```rs
struct Container<T> {
  value: T,
}

impl<T> Container<T> {
  fn process(&self) -> &'static str { "generic implementation" }
}

impl Container<i32> {
  fn process(&self) -> &'static str { "specialized implementation for i32" }
}
```

#qa[Will this code compile?][No. Rust does not allow overlapping implementations.]


== `impl Trait`

#slide[
  #set text(size: 0.8em)

  #info[`impl Into<i32>` is syntactic sugar for: ` fn add_42_millions<T: Into<i32>>(x: T) -> i32`.\ `T` is an  anonymous and *hidden generic type*.]


  #codly(
    highlights: (
      (line: 1, start: 23, end: 36, fill: red),
      (line: 5, start: 23, end: 32, fill: red),
    ),
  )
  ```rs
  fn add_42_millions(x: impl Into<i32>) -> i32 {
      x.into() + 42_000_000
  }

  fn pair_of(x: u32) -> impl Debug {
      (x + 1, x - 1)
  }

  fn main() {
      let many = add_42_millions(42_i8);
      dbg!(many);
      let many_more = add_42_millions(10_000_000);
      dbg!(many_more);
      let debuggable = pair_of(27);
      dbg!(debuggable);
  }
  ```
]


#slide[
  === Inference for return type `impl Trait`

  #codly(
    highlights: (
      (line: 1, start: 34, end: 45, fill: red),
    ),
  )
  ```rs
  fn returns_impl_trait(x: i32) -> impl Display {
      if x > 0 {
          x
      } else {
          -x
      }
  }

  fn main() {
      let result = returns_impl_trait(-5);
      println!("{}", result);
  }
  ```

  #qa[What is the return type of `returns_impl_trait`?][`i32`, because both branches return an `i32`.]
]


== Exercise

Please find the exercise in `./session-2/tests/s2e4-min.rs`.

Test using the command: `cargo test --test s2e4-min -- --nocapture`
