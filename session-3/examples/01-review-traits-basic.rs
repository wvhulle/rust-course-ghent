//! # Implementing traits
//!
//! Implement a simple Shape trait for different geometric shapes
//! (Notice that top-level comments like this, with !, document the object they
//! are contained in.)
#![allow(unused)]
/// A two-dimensional figure. The trait that you will implement.
trait Shape {
    /// Calculates the surface area of the shape.
    fn area(&self) -> f64;
}

// Start of demo code:

struct Rectangle {
    width: f64,
    height: f64,
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

// Start exercise:

struct Triangle {
    base: f64,
    height: f64,
}

impl Shape for Triangle {
    fn area(&self) -> f64 {
        // Todo is a placeholder that should be replaced by your functinal code.
        todo!("Implement area for Triangle")
    }
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        todo!("Implement area for Circle")
    }
}

fn print_area<T: Shape>(_shape: &T) {
    todo!("Print the area of the shape")
}

/// Small script to print debugging information to the terminal / STDOUT.
fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    // Use the `dbg!` macro for debugging. Replace by `log` in production.
    // Notice: inline // commands are not automatically documented in
    // [doc.rs](doc.rs).
    dbg!(rect.area());

    todo!("Create a Triangle with base=6.0 and height=4.0, then print its area");

    todo!("Create a Circle with radius=3.0, then print its area");

    todo!("Use print_area() function on all three shapes");
}
