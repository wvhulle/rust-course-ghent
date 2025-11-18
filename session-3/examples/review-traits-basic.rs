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
        todo!("Implement area for Triangle: (base * height) / 2.0")
    }
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        todo!("Implement area for Circle: π * radius². Hint: Use std::f64::consts::PI")
    }
}

fn print_area<T: Shape>(_shape: &T) {
    todo!("Print the area of the shape")
}

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    println!("Rectangle area: {}", rect.area());

    todo!("Create a Triangle with base=6.0 and height=4.0, then print its area");

    todo!("Create a Circle with radius=3.0, then print its area");

    todo!("Use print_area() function on all three shapes");
}
