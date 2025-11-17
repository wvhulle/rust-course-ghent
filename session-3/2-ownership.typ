
#import "../template.typ": *


= Ownership

== Memory layout

```rust
fn main() {
    let s1 = String::from("Hello");
}
```

#qa[

  What data does the `s1` variable contain at runtime?

][Capacity, address buffer, length.]

#image("images/string.png", height: 50%)


#pagebreak()



== Stack and heap



#fletcher-diagram(
  node-shape: rect,
  spacing: (15mm, 8mm),

  // Stack section
  node((0, 0), [*Stack*], stroke: none, name: <stack-title>),
  node((0, 1), [`main()` frame\ `x: i32 = 5`], fill: blue.lighten(80%), name: <frame1>),
  node((0, 2), [`foo()` frame\ `y: bool = true`], fill: blue.lighten(80%), name: <frame2>),
  node((0, 3), [`bar()` frame\ `s: Box<...>`], fill: blue.lighten(80%), name: <frame3>),

  // Stack pointer indicator
  node((0, 4), [Stack pointer ↓], stroke: none, name: <sp>),

  edge(<frame1>, <frame2>, "->", stroke: 2pt + blue),
  edge(<frame2>, <frame3>, "->", stroke: 2pt + blue),
  edge(<frame3>, <sp>, "->", stroke: 2pt + blue, label: [Grows], label-side: right),

  node(enclose: (<frame1>, <frame2>, <frame3>, <sp>), stroke: blue),

  // Heap section
  node((3, 0), [*Heap*], stroke: none, name: <heap-title>),
  node((3, 1.5), [Allocated\ block], fill: orange.lighten(70%), width: 15mm, name: <heap1>),
  node((4, 2.8), [Free\ space], fill: gray.lighten(80%), width: 12mm, name: <free1>),
  node((2.5, 3.2), [Allocated\ block], fill: orange.lighten(70%), width: 15mm, name: <heap2>),
  node((3.8, 1), [Free\ space], fill: gray.lighten(80%), width: 10mm, name: <free2>),

  // Pointer from stack to heap
  edge(<frame3>, <heap2>, "->", stroke: 2pt + red, label: [Points to], label-side: center, bend: 20deg),

  // Annotations
  node((-1, 4), [Fast: pointer bump\ Fixed max size], stroke: none, fill: none),
  node((3, 4), [Slower: search & bookkeeping\ Dynamic size], stroke: none, fill: none),

  node(enclose: (<heap1>, <free1>, <heap2>, <free2>), label: [Heap memory area], stroke: orange),
)

#pagebreak()

```rust
fn main() {
    let mut s1 = String::from("Hello");
    s1.push(' ');
    s1.push_str("world");
    // DON'T DO THIS AT HOME! For educational purposes only.
    // String provides no guarantees about its layout, so this could lead to
    // undefined behavior.
    unsafe {
        let (capacity, ptr, len): (usize, usize, usize) = std::mem::transmute(s1);
        println!("capacity = {capacity}, ptr = {ptr:#x}, len = {len}");
    }
}
```



== Memory challenges

#qa[What is the most important challenge when managing memory?][Memory corruption.]

#qa[What are common causes of memory corruption?][Dangling pointers (use after free), double frees, buffer overflows.]

#qa[What are the two different strategies to avoid memory corruption][Automatic or manual memory management.]

#focus-slide[
  #image("images/garbage.jpg")
]

== Ownership

Every Rust value has precisely one owner at all times.

```rust
struct Point(i32, i32);

fn main() {
    {
        let p = Point(3, 4);
        dbg!(p.0);
    }
    dbg!(p.1);
}
```

#qa[What does this have in common with automatic garbage collection?][Rust's ownership system uses roots as well, but roots are determined statically at compile time.]

== Move semantics


```rust
fn main() {
    let s1 = String::from("Hello!");
    let s2 = s1;
    dbg!(s2);
    // dbg!(s1);
}
```

#qa[What is the ownership flow?][`s1` owns the string. When `s1` is assigned to `s2`, ownership moves to `s2`. `s1` is no longer valid.]

#pagebreak()

#image("images/move.png")


#pagebreak()

When you pass a value to a function, the value is assigned to the function parameter. This transfers ownership:

```rust
fn say_hello(name: String) {
    println!("Hello {name}")
}

fn main() {
    let name = String::from("Alice");
    say_hello(name);
    // say_hello(name);
}
```

#qa[How does this differ from what C++ does?][
  C++ copies the value by default, unless you use references or move semantics explicitly.
]

#pagebreak()

#qa[How do you restore C++ behaviour where you copy when necessary?][Derive the `Copy` trait.]

```rust
fn main() {
    let x = 5;
    let y = x;
    println!("x = {x}, y = {y}");
}
```

#qa[Are `String`s in Rust `Copy`? (Do they get cloned automatically on assignment?)][No.]


== Clone

```rs
fn say_hello(name: String) {
    println!("Hello {name}")
}

fn main() {
    let name = String::from("Alice");
    say_hello(name.clone());
    say_hello(name);
}
```

#pagebreak()

Values which implement Drop can specify code to run when they go out of scope:

```rs
struct Droppable {
    name: &'static str,
}

impl Drop for Droppable {
    fn drop(&mut self) {
        println!("Dropping {}", self.name);
    }
}
```


#slide[
  #set text(size: 0.8em)
  ```rs
  fn main() {
      let a = Droppable { name: "a" };
      {
          let b = Droppable { name: "b" };
          {
              let c = Droppable { name: "c" };
              let d = Droppable { name: "d" };
              println!("Exiting innermost block");
          }
          println!("Exiting next block");
      }
      drop(a);
      println!("Exiting main");
  }
  ```
  #qa[Explain what will be printed?][...]
]

#focus-slide[
  #image("images/chinese.jpg")
]

== Exercise

#slide[
  #set text(size: 0.8em)



  === Google

  - `session-3/examples/s3e4-builder.rs`
][
  === Rustlings


  - 05_vecs/
  - 09_strings/
  - 06_move_semantics/
]
