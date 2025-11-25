//! Try to create a non-consuming iterator that loops over an owned string (without consuming it) lazily.
//!
//! You will need to implement a struct that holds a reference to the string. Structs that hold references need a lifetime parameter.
//!
//! Then you will need to implement the `Iterator` struct over this custom iterator struct.
//!
fn main() {
    let s = String::from("hello");
    let mut iter = StringIterator::new(&s);

    while let Some(c) = iter.next() {
        println!("{}", c);
    }

    // Ensure the original string is still accessible
    println!("Original string: {}", s);
}
