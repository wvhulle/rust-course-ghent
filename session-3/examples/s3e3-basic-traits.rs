// Basic Trait Implementation
//
// In Rust, traits define shared behavior similar to interfaces in other languages.
// Unlike C++ abstract classes, traits:
// - Don't contain data (only method signatures)
// - Can be implemented for any type, even those you didn't define
// - Allow compile-time polymorphism through generics
//
// Your task: Implement a simple Shape trait for different geometric shapes

#![allow(unused_variables)]
#![allow(dead_code)]

trait Shape {
    fn area(&self) -> f64;
}

struct Rectangle {
    width: f64,
    height: f64,
}

// Example implementation
impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

// TODO: Define a new struct called `Triangle` with fields:
// - base: f64
// - height: f64

// TODO: Implement Shape for Triangle
// Area formula: (base * height) / 2.0

// TODO: Define a new struct called `Circle` with field:
// - radius: f64

// TODO: Implement Shape for Circle
// Area formula: π * radius²
// Hint: Use std::f64::consts::PI

// TODO: Write a generic function called `print_area` that takes any type
// implementing Shape and prints its area
// Hint: fn print_area<T: Shape>(shape: &T)

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    println!("Rectangle area: {}", rect.area());

    // TODO: Create a Triangle instance and print its area
    
    // TODO: Create a Circle instance and print its area
    
    // TODO: Use your print_area function on all three shapes
}
