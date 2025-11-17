
#import "../template.typ": *

= Standard library traits

== Comparison

```rust
struct Key {
    id: u32,
    metadata: Option<String>,
}
impl PartialEq for Key {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id
    }
}
```

#qa[Can equality be implemented between different types?][No, both types must be the same or one must implement `PartialEq` for the other type.]

#pagebreak()

```rust
use std::cmp::Ordering;
#[derive(Eq, PartialEq)]
struct Citation {
    author: String,
    year: u32,
}
impl PartialOrd for Citation {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        match self.author.partial_cmp(&other.author) {
            Some(Ordering::Equal) => self.year.partial_cmp(&other.year),
            author_ord => author_ord,
        }
    }
}
```

#pagebreak()

#qa[When two references (not pointers) point to an equal object, are they equal?][Yes, references implement `PartialEq` by dereferencing both sides and comparing the underlying values.]

```rust
fn main() {
    let a = "Hello";
    let b = String::from("Hello");
    assert_eq!(a, b);
}
```


#pagebreak()

```rust
#[derive(Debug, Copy, Clone)]
struct Point {
    x: i32,
    y: i32,
}

impl std::ops::Add for Point {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self { x: self.x + other.x, y: self.y + other.y }
    }
}
```

#qa[What happens if you write Not (`!`) in front of something that is not a boolean?][It flips each bit.]



#pagebreak()

```rust
fn main() {
    let s = String::from("hello");
    let addr = std::net::Ipv4Addr::from([127, 0, 0, 1]);
    let one = i16::from(true);
    let bigger = i32::from(123_i16);
    println!("{s}, {addr}, {one}, {bigger}");
}
```

#qa[When you have a `From` implementation, do you receive a blanket `Into` implementation?][Yes.]

#qa[When you have an `Into` implementation, do you receive a blanket `From` implementation?][No.]

#warning[Always implement `From` for your own types.]

== Casting

#focus-slide[
  #image("images/transform.png")
]


```rust
fn main() {
    let value: i64 = 1000;
    println!("as u16: {}", value as u16);
    println!("as i16: {}", value as i16);
    println!("as u8: {}", value as u8);
}
```

#warning[Prefer using `From` and `Into` over `as` casting whenever possible.]

#qa[Which trait should I use when casting is fallible (may go wrong)?][Use the `TryFrom` and `TryInto` traits.]



#pagebreak()


```rust
use std::io::{BufRead, BufReader, Read, Result};

fn count_lines<R: Read>(reader: R) -> usize {
    let buf_reader = BufReader::new(reader);
    buf_reader.lines().count()
}

fn main() -> Result<()> {
    let slice: &[u8] = b"foo\nbar\nbaz\n";
    println!("lines in slice: {}", count_lines(slice));

    let file = std::fs::File::open(std::env::current_exe()?)?;
    println!("lines in file: {}", count_lines(file));
    Ok(())
}
```

#pagebreak()

```rust
use std::io::{Result, Write};

fn log<W: Write>(writer: &mut W, msg: &str) -> Result<()> {
    writer.write_all(msg.as_bytes())?;
    writer.write_all("\n".as_bytes())
}

fn main() -> Result<()> {
    let mut buffer = Vec::new();
    log(&mut buffer, "Hello")?;
    log(&mut buffer, "World")?;
    println!("Logged: {buffer:?}");
    Ok(())
}
```

#focus-slide[
  #image("images/chinese.jpg")
]

#slide[
  === Rustlings

  - 23_conversions/
][
  === Google
  - `Read` trait: `session-3/tests/s3e1-rot.rs`
]



== Default

#slide[
  #set text(size: 0.7em)

  ```rust
  #[derive(Debug, Default)]
  struct Derived {
      x: u32,
      y: String,
      z: Implemented,
  }

  #[derive(Debug)]
  struct Implemented(String);

  impl Default for Implemented {
      fn default() -> Self { Self("John Smith".into()) }
  }

  fn main() {
      let default_struct = Derived::default();
      dbg!(default_struct);

      let almost_default_struct =
          Derived { y: "Y is set!".into(), ..Derived::default() };
      dbg!(almost_default_struct);

      let nothing: Option<Derived> = None;
      dbg!(nothing.unwrap_or_default());
  }
  ```
]
