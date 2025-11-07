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

```rs
fn pick_i32(cond: bool, left: i32, right: i32) -> i32 {
    if cond { left } else { right }
}

fn pick_char(cond: bool, left: char, right: char) -> char {
    if cond { left } else { right }
}
```

Generics are a zero-cost abstraction.

== Trait bounds

Require the types to implement some trait, so that you can call this trait’s methods

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

#qa[What happens if we pass NotCloneable to duplicate? (Try in playground!)][A compile-time error, because NotCloneable does not implement the Clone trait.]


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

== Generic datatypes

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

== If `X` impl, then `Y` impl

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

#qa[Why is L specified twice in `impl<L: Logger>` .. `VerbosityFilter<L>`? Isn't that redundant?][`impl` parameters are separate and usually carries trait bounds (not the datatype).]


== Usage

```rust
fn main() {
    let logger = VerbosityFilter { max_verbosity: 3, inner: StderrLogger };
    logger.log(5, "FYI");
    logger.log(2, "Uhoh");
}
```

== Generic traits

The `From` trait is a standard library trait for type conversion.

```rs
pub trait From<T>: Sized {
    fn from(value: T) -> Self;
}

#[derive(Debug)]
struct Foo(String);
```


== Conversion with `From`

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


== Associated types versus generic types

It may not always be clear when to pick an associated type or a generic type.

#fletcher-diagram(
  spacing: (6em, 3em),
  node((0, 0), [Generic \ datatype], name: <type>, fill: green.lighten(70%)),
  node((1, 0), [Trait], name: <trait>, fill: orange.lighten(70%)),
  node((0.5, 2), [Single, unique \ associated type], name: <assoc-type>),
  edge(<trait>, <assoc-type>, "->"),
  edge(<type>, <assoc-type>, "->"),

  node((1.5, -0.5), name: <div-up>),
  node((1.5, 2.5), name: <div-down>),
  edge(<div-up>, <div-down>, "="),

  node((2.5, 0), [Generic\ datatype], name: <type-gen>, fill: green.lighten(70%)),
  node((2, 1), [Concrete datatype \ `impl` block 1], name: <impl-block-1>),
  node((3, 1), [Concrete datatype \ `impl` block 2], name: <impl-block-2>),
  node((2.5, 2), [Generic\ trait], name: <trait-assoc>, fill: orange.lighten(70%)),
  edge(<impl-block-1>, <impl-block-2>, ".."),
  edge(<type-gen>, <impl-block-1>, "->"),
  edge(<type-gen>, <impl-block-2>, "->"),
  edge(<impl-block-1>, <trait-assoc>, "->"),
  edge(<impl-block-2>, <trait-assoc>, "->"),
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
