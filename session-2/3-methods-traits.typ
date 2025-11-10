#import "../template.typ": *

= Tooling intermezzo

== Debugger

#focus-slide(
  image("./images/debugger.png"),
)

== Clippy
#slide[
  #image("./images/clippy.png")
]

#slide[

  Most useful lints:

  - complexity
  - style
  - correctness

  Place clippy rules in your `Cargo.toml` like this:

  ```toml
  [lints.clippy]
  complexity = { level = "deny", priority = -1 }
  pedantic = { level = "deny", priority = -1 }
  style = { level = "deny", priority = -1 }

  absolute_paths = "deny"
  allow_attributes_without_reason = "deny"
  ...
  ```

  Find more lint rules at #link("https://rust-lang.github.io/rust-clippy/master/index.html")[rust-lang.github.io/rust-clippy].

]

== Summary

#slide[
  Typical development workflow in Rust:

  1. Debug with GDB / LLDB or VS Code
  2. Format with `cargo fmt`
  3. Lint with `cargo clippy`
  4. Test with `cargo test`
  5. Build with `cargo build` or `cargo build --release`
]

= Methods and traits

== Methods

#slide[
  #set text(size: 0.7em)

  In Rust, methods are separated from fields:

  ```rust
  #[derive(Debug)]
  struct CarRace {
      name: String,
      laps: Vec<i32>,
  }

  impl CarRace {
      // No receiver, a static method
      fn new(name: &str) -> Self {
          Self { name: String::from(name), laps: Vec::new() }
      }
      // Exclusive borrowed read-write access to self
      fn add_lap(&mut self, lap: i32) {
          self.laps.push(lap);
      }
  }

  fn main() {
      let mut race = CarRace::new("Monaco Grand Prix");
      race.add_lap(70);
  }
  ```

]

#slide[
  #set text(size: 0.8em)
  Like in other languages, methods group functionality around _acting_ data types, types that _do_ related things.

  #qa[
    How are methods in Rust different from methods in other languages?
  ][
    Methods cannot be overridden.
  ]

  #codly(
    highlights: (
      (line: 2, start: 16, end: 24),
    ),
  )
  ```rust
  impl CarRace {
      fn add_lap(&mut self, lap: i32) {
          self.laps.push(lap);
      }
  }
  ```
  #qa[What is the `&mut self` parameter syntax sugar for?][For `self: &mut Self`.]
  #codly(
    highlights: (
      (line: 2, start: 16, end: 30),
    ),
  )
  ```rust
  impl CarRace {
      fn add_lap(self: &mut Self, lap: i32) {
          self.laps.push(lap);
      }
  }
  ```
]

#slide[
  #set text(size: 0.7em)
  Methods can *consume* `self`:


  #codly(
    highlights: (
      (line: 9, start: 8, end: 19),
    ),
  )
  ```rust
  #[derive(Debug)]
  struct CarRace {
      name: String,
      laps: Vec<i32>,
  }

  impl CarRace {
      // Exclusive ownership of self (covered later)
      fn finish(self) {
          let total: i32 = self.laps.iter().sum();
          println!("Race {} is finished, total lap time: {}", self.name, total);
      }
  }

  fn main() {
      let mut race = CarRace::new("Monaco Grand Prix");
      race.add_lap(70);
      race.finish();
      // race.add_lap(42);
  }
  ```
][
  #pause

  #qa[What is the name given to the `self` parameter in methods?][
    `self` is called the *receiver*.
  ]

  After calling a method with `object.finish(self)`, you can no longer use `object`. It has been _consumed_.

  #warning[
    Use the `self` receiver to define destructors or functionality that should happen only once at the end.
  ]
]

== Receivers

#slide[

  Rust allows receivers to be one of the following:

  - `self`, consuming self
  - any kind of reference to self: `&self`, `&mut self`
  - exceptions (covered later)


  #qa[Name a few reference types in Rust.][`&T`, `&mut T`, `Box<T>`, `Rc<T>`, `Arc<T>`, ...]

  #info[Reference types are also called *wrappers* and some are *smart pointers*.]

]


== Traits

#slide[
  Rust lets you abstract over types with traits. Similar to interfaces:

  ```rust
  trait Pet {
      /// Return a sentence from this pet.
      fn talk(&self) -> String;

      /// Print a string to the terminal greeting this pet.
      fn greet(&self);
  }
  ```
  Properties of traits:
  #pause
  - A trait is a list of methods that a type *must implement*
  #pause
  - The *signatures* of the type's methods *must be identical* to the trait's method signatures
  #pause

  #info[*Default implementations* can be provided]
]

== Implementing traits

#slide[

  ```rust
  trait Pet {
    fn talk(&self) -> String;

    fn greet(&self) {
        println!("Oh you're a cutie! What's your name? {}", self.talk());
    }
  }

  struct Dog {
    name: String,
    age: i8,
  }
  ```
][
  #set text(size: 0.8em)

  #pause
  ```rust
  impl Pet for Dog {
    fn talk(&self) -> String {
        format!("Woof, my name is {}!", self.name)
    }
  }

  fn main() {
    let fido = Dog { name: String::from("Fido"), age: 5 };
    dbg!(fido.talk());
    fido.greet();
  }
  ```
  #pause
  #warning[
    a Cat type with a `talk()` method would not automatically satisfy Pet unless it is in an impl Pet block
  ]
]

#slide[
  You can:

  - split trait implementation blocks
  - override default method implementations

  ```rust
    impl Pet for Dog {
        fn talk(&self) -> String {
            format!("Woof, my name is {}!", self.name)
        }
    }

    impl Pet for Dog {
        fn greet(&self) -> String {
            format!("Woof, my name is {}!", self.name)
        }
    }
  ```

]

== Contracts


#focus-slide[
  #image("./images/contract.png")
]


#slide[
  Rust, being a systems programming language, focuses on safety.

  #pause

  In Rust documentation, you will often encounter the word *contract*.

  #info[A contract is an agreement between two parties. There are mainly two kinds of contracts in Rust:

    - Contracts between *two pieces of code*
    - Contracts between *the programmer and the compiler*

  ]

  #pause

  Contracts between two pieces of code are generally safe (can be enforced automatically). #pause


  #warning[... but contracts between the programmer and the compiler can be unsafe or *may have to be checked by the programmer*.]

  Examples of such contracts: `Pin`, `Send`, `Sync` traits (advanced topic).

]



== Super-traits


#slide[
  #set text(size: 0.8em)


  ```rust
  trait Animal {
      fn leg_count(&self) -> u32;
  }

  trait Pet: Animal {
      fn name(&self) -> String;
  }

  struct Dog(String);

  impl Animal for Dog {
      fn leg_count(&self) -> u32 {
          4
      }
  }

  impl Pet for Dog {
      fn name(&self) -> String {
          self.0.clone()
      }
  }
  ```


][

  *Super-traits* are an extra constraint on traits that say: "to implement this trait, you must also implement that other trait".

  #pause

  #warning[
    Super traits are the kind of language feature you should *avoid as long as you are stuck with the OOP mindset*.]

  Once you are willing to forget OOP, you can see super-traits are actually easy.

  #pause

  #info(title: [Advanced])[... at least as long as you don't constrain *associated types* of super traits in subtraits ]

]


== Associated Types

#slide[
  #set text(size: 0.7em)

  #codly(
    highlights: (
      (line: 7, start: 5, end: 15, fill: red),
      (line: 12, start: 5),
    ),
  )
  ```rust
  #[derive(Debug)]
  struct Meters(i32);
  #[derive(Debug)]
  struct MetersSquared(i32);

  trait Multiply {
      type Output;
      fn multiply(&self, other: &Self) -> Self::Output;
  }

  impl Multiply for Meters {
      type Output = MetersSquared;
      fn multiply(&self, other: &Self) -> Self::Output {
          MetersSquared(self.0 * other.0)
      }
  }

  fn main() {
      println!("{:?}", Meters(10).multiply(&Meters(20)));
  }
  ```
][
  Associated types are *placeholder types that* are supplied by the trait implementation.


  #pause

  #qa[Why are associated types are sometimes also called "output types"][The implementer, not the caller, chooses the concrete associated type. ]

  #pause



  Iterators from the standard library have an associated type `Item`:

  ```rust
  pub trait Iterator {
      type Item;
      fn next(&mut self) -> Option<Self::Item>;
  }
  ```

]

#slide[

  #fletcher-diagram(
    spacing: (7em, 4em),
    node((0, 0), [Trait with \ associated types], stroke: blue.lighten(50%)),
    node((0.5, 0.5), [Ass. type A \ placeholder], stroke: blue.lighten(50%)),
    node((0.7, 0), [Ass. type B \ placeholder], stroke: blue.lighten(50%)),
    node((0.5, -0.5), [Ass. type C \ placeholder], stroke: blue.lighten(50%)),

    node((0, 0 + 2), [Concrete protocl], fill: blue.lighten(50%)),
    node((0.5, 0.5 + 2), [Concrete \ ass. type A], fill: blue.lighten(50%)),
    node((0.7, 0 + 2), [Concrete \ ass. type B], fill: blue.lighten(50%)),
    node((0.5, -0.5 + 2), [Concrete ass. Type C], fill: blue.lighten(50%)),
  )
]


== Deriving

#slide[
  #set text(size: 0.8em)
  Supported traits can be automatically implemented for your custom types, as follows:

  ```rust
  #[derive(Debug, Clone, Default)]
  struct Player {
      name: String,
      strength: u8,
      hit_points: u8,
  }

  fn main() {
      let p1 = Player::default(); // Default trait adds `default` constructor.
      let mut p2 = p1.clone(); // Clone trait adds `clone` method.
      p2.name = String::from("EldurScrollz");
      // Debug trait adds support for printing with `{:?}`.
      println!("{p1:?} vs. {p2:?}");
  }
  ```

  #qa[How is the derive functionality implemented in Rust?][With *procedural macros*, and many crates provide useful derive macros to add useful functionality.]

  #pause
  For example, `serde` can derive serialization support for a struct using `#[derive(Serialize)]`.
]

#slide[
  === Why is deriving useful?

  A manual implementation of the `Clone` trait for the `Player` struct would look like this:

  ```rust
  impl Clone for Player {
      fn clone(&self) -> Self {
          Player {
              name: self.name.clone(),
              strength: self.strength.clone(),
              hit_points: self.hit_points.clone(),
          }
      }
  }
  ```

  It is easier to just write `#[derive(Clone)]`

  #info[The derive attribute is similar to `deriving` in Haskell.]
]

== Exercise: Logger trait

#slide[

  Complete the test code in `session-2/examples/s2e3-logger.rs`.

  Run code with `cargo run --example s2e3-logger`.


]

