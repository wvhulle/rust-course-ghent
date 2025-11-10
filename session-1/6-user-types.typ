#import "../template.typ": *

= User-defined types

== Named `struct`s

#slide[

  Exactly the same as in C/C++:

  ```rust
  struct Person {
      name: String,
      age: u8,
  }

  fn describe(person: &Person) {
      println!("{} is {} years old", person.name, person.age);
  }
  ```


]


#slide[

  === Usage

  ```rust
  struct Person {
      name: String,
      age: u8,
  }

  fn main() {
      let name = String::from("Peter");
      let mut peter = Person {
          name,
          age: 27,
      };
      describe(&peter);
      peter.age = 28;
  }
  ```

  #warning[Struct fields do not support default values.]

  Use the `Default` trait to implement default values (see later).
]


#slide[
  === Inheritance



  #qa[How does Rust handle `struct` inheritance (like class inheritance in other languages?][
    Rust explicitly forbids `struct` inheritance.
  ]

  #warning[Inheritance in Rust is replaced by trait composition.]


  #info[Only abstract interfaces can be inherited, concrete types such as `struct`s cannot.]


]


== Tuple `struct`s

#slide[
  If the field names are unimportant, you can use a tuple struct:

  ```rust
    struct Point(i32, i32);

  fn main() {
      let p = Point(17, 23);
      println!("({}, {})", p.0, p.1);
  }
  ```
]

#focus-slide[
  #image("images/orbiter.jpg")
]

#slide[


  #qa[What is the name of this satellite?][Mars Climate Orbiter]

  #qa[Why did it fail?][A unit conversion error: one team used imperial units (pounds of force), the other metric (Newtons).]
]


#slide[

  === Usage

  This is often used for single-field wrappers (called newtypes):
  ```rust
  struct PoundsOfForce(f64);
  struct Newtons(f64);

  fn compute_thruster_force() -> PoundsOfForce {
      todo!("Ask a rocket scientist at NASA")
  }

  fn set_thruster_force(force: Newtons) {
      // ...
  }

  fn main() {
      let force = compute_thruster_force();
      set_thruster_force(force);
  }
  ```
]

#slide[
  === Remarks

  - Great way to encode additional information about the value in a primitive type
  - Value passed some validation when it was created, so you no longer have to validate it again at every use


  #qa[How do you prevent invalidation of the value after validation during creation?][Keep the inner field private by adding `pub` only to the struct, not to its fields.]
]


== Enums

#slide[


  #grid(columns: (1fr, 1fr))[
    The `enum` keyword allows the creation of a type which has a few different variants:

    ```rust
    #[derive(Debug)]
    enum Direction {
        Left,
        Right,
    }
    ```
  ][
    ```rs
    #[derive(Debug)]
    enum PlayerMove {
        Pass,
        Run(Direction),
        Teleport { x: u32, y: u32 },
    }
    ```
  ]
  ```rs
  fn main() {
       let dir = Direction::Left;
       let player_move: PlayerMove = PlayerMove::Run(dir);
       println!("On this turn: {player_move:?}");
   }
  ```
]

#slide[
  === Storage of `enum`

  #info[An `enum` occupies enough space to store *its largest variant* plus some extra space to store which variant it currently is.]


  ```rust
    #[repr(u32)]
  enum Bar {
      A, // 0
      B = 10000,
      C, // 10001
  }

  fn main() {
      println!("A: {}", Bar::A as u32);
      println!("B: {}", Bar::B as u32);
      println!("C: {}", Bar::C as u32);
  }
  ```

  Without repr, the discriminant type takes 2 bytes, because 10001 fits 2 bytes.
]

#focus-slide[
  #image("images/tony_hoare.jpg")
]

#slide[




  #qa[Who is Tony Hoare and what was his billion dollar mistake?][Tony Hoare is a British computer scientist who invented the null reference in 1965 while designing the ALGOL W programming language. ]
]


#slide[

  === Option enum


  The simplest example of an enum is the `Option<T>` type, which represents either a value of type `T` or no value at all:

  ```rust
  enum Option<T> {
      None,
      Some(T),
  }
  ```


  #qa[How much space does `Option<&u8>` occupy?][The same as a single reference (8 bytes on 64-bit), because  `None` is represented as a null pointer, so no extra discriminant space is needed.]

  #pause

  #info[For the functional programmers: `Option` is also a *monad*, but in Rust monadic `do` notation is replaced by the short-circuiting `?` operator.]


]


== Compile-time `const`



#slide(composer: (1fr, 1fr))[
  ```rust
  const fn is_prime(n: u32) -> bool {
      if n < 2 { return false; }
      let mut i = 2;
      while i * i <= n {
          if n % i == 0 { return false; }
          i += 1;
      }
      true
  }

  fn main() {
      println!("First 25 primes: {:?}",
               PRIMES_BELOW_100);
  }
  ```
][
  ```rust
  const PRIMES_BELOW_100: [u32; 25] = {
      let mut primes = [0; 25];
      let mut count = 0;
      let mut n = 2;
      while n < 100 {
          if is_prime(n) {
              primes[count] = n;
              count += 1;
          }
          n += 1;
      }
      primes
  };
  ```

  #info[The prime sieve runs at *compile time*, resulting in zero runtime overhead!]
]


#slide[
  #info[Similar to C++'s `constexpr`, Zig's `comptime`]

  #pause

  #qa[What are the limitations of `const fn`?][
    - Cannot allocate heap memory
    - Cannot call non-`const` functions
    - Cannot use floating-point operations (being relaxed in newer Rust versions)
    - Limited to a subset of Rust operations
  ]

  #pause

  #qa[Why these restrictions?][To guarantee deterministic, side-effect-free compile-time evaluation with predictable performance.]
]

== Static

#slide[
  Static variables will live during the whole execution of the program, and therefore will not move:

  ```rust
  static BANNER: &str = "Welcome to RustOS 3.14";

  fn main() {
      println!("{BANNER}");
  }
  ```

  #info[Accessible from any thread.]

  #warning[Not inlined upon use and have an actual associated memory location.]

  #qa[Why is this often used in embedded Rust?][Stable addresses are often required. Memory shared between cores. No heap allocation is available.]
]

#slide[
  === `static OnceLock` pattern

  When a `static` needs to be initialised at runtime (just once) and is read-only, use `OnceLock`:

  ```rust
  use std::sync::OnceLock;

  static CONFIG: OnceLock<Config> = OnceLock::new();

  fn main() {
      CONFIG.get_or_init(|| {
          Config::load("config.toml")
      });
  }
  ```

]


#focus-slide[
  #image("images/plant_pot_participants.jpg")
]

#slide[
  #set text(size: 0.9em)
  === Plant pot workshop

  A few months ago, at this location, we built an embedded Rust plant pot monitor together


  Instructions available at  #link("https://github.com/sysghent/plant-pot").

  #codly(
    highlights: ((line: 1, start: 0, end: 30),),
  )
  ```rust
  static HUMIDITY_PUBSUB_CHANNEL:
    PubSubChannel<CriticalSectionRawMutex, f32, 1, 3, 1> =
      PubSubChannel::new();

  #[main]
  async fn main(spawner: Spawner) -> ! {
      let p = embassy_rp::init(config::Config::default());
      let adc_component = Adc::new(p.ADC, Irqs, Config::default());
      // ...
    }
  ```

  #pause

  In embedded Rust, you either use the `OnceLock`
  or `const` functions to initialise `static` variables.

  #qa[Where is the `const fn` function in this fragment and how to find out?][(In this example `PubSubChannel::new()` is a `const fn`.)]

]

== Summary: World map

#slide[
  #fletcher-diagram(
    spacing: (1.8em, 1.5em),

    node((0, -0.5), [*Compile-time \ world*], name: <compile-time>),

    node((-0.5, 1), name: <header-left>),
    node((5, 1), name: <header-right>),
    edge(<header-left>, <header-right>, "-"),
    pause,

    node((0, 2), [`const` \ variables], name: <static-vars>),
    pause,
    node((0, 3), [`const fn` \ functions], name: <const-fn>),
    pause,
    node((0, 4), [`const` \ generics], name: <const-gen>),

    pause,
    node((0.5, -1), name: <compile-div-top>),
    node((0.5, 5), name: <compile-div-bottom>),
    edge(<compile-div-top>, <compile-div-bottom>, "=", stroke: gray),
    pause,


    node((2, -0.5), [*Runtime \ world*], name: <runtime>),
    pause,

    node((1, 0), text(fill: gray)[Wild West: \  embedded], name: <wild-west>),
    pause,
    node((1, 2), [`OnceLock` \ `LazyLock` \ "init on use"], name: <once-lock>),

    pause,
    node((1, 3), [`unsafe` code], name: <unsafe-code>),

    pause,


    node((2, 0), name: <runtime-div-top>),
    node((2, 4), name: <runtime-div-bottom>),
    edge(<runtime-div-top>, <runtime-div-bottom>, "..", stroke: gray),

    node((3, 0), text(fill: gray)[Safe \ Rust], name: <safe-rust>),

    pause,
    node((3, 2), [Heap \ allocation], name: <heap>),
    pause,
    node((3, 3), [Normal \ functions], name: <normal-fn>),
    pause,
    node((4, 2), [Mutable \ variables], name: <mutable-vars>),
  )
]

== Exercise: Elevator Events

#slide[
  === Goal

  Create a data structure to represent an event in an elevator control system.

  Complete the code in `session-1/examples/s1e3-elevator.rs`.

]
