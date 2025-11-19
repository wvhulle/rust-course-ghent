//! Implement a simple Shape trait for different geometric shapes

trait Shape {
    fn area(&self) -> f64;
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

struct Triangle {
    base: f64,
    height: f64,
}

impl Shape for Triangle {
    fn area(&self) -> f64 {
        // TODO: Implement area for Triangle (base * height / 2.0)
        todo!("implement")
    }
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        // TODO: Implement area for Circle (use std::f64::consts::PI)
        todo!("implement")
    }
}

fn print_area<T: Shape>(_shape: &T) {
    // TODO: Print the area of the shape
    todo!("use self")
}

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    dbg!(rect.area());

    // TODO: Create a Triangle with base=6.0 and height=4.0
    // TODO: Call dbg! on its area

    // TODO: Create a Circle with radius=3.0
    // TODO: Call dbg! on its area

    // TODO: Call print_area() on rect, triangle, and circle
}
