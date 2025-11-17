// COMPREHENSIVE EXAMPLE: Traits, Supertraits, and Dispatch
//
// This file combines all the concepts from exercises s3e3 through s3e6.
// Complete the individual exercises first before studying this example!
//
// Covered concepts:
// 1. Basic trait implementation (s3e3-basic-traits.rs)
// 2. Supertraits (s3e4-supertraits.rs)
// 3. Multiple trait bounds (s3e5-multiple-bounds.rs)
// 4. Static vs Dynamic dispatch (s3e6-dispatch.rs)
//
// Key differences from C++ multiple inheritance:
// 1. Traits don't contain data (no field inheritance)
// 2. Supertraits are constraints, not virtual base classes
// 3. No diamond problem with data duplication
// 4. Trait objects provide dynamic dispatch (like C++ virtual methods)

#![allow(unused_variables)]
#![allow(dead_code)]

trait Shape {
    fn area(&self) -> f64;
}

trait Colored: Shape {
    fn color(&self) -> &str;
}

trait Named: Shape {
    fn name(&self) -> &str;
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

impl Colored for Rectangle {
    fn color(&self) -> &str {
        "red"
    }
}

impl Named for Rectangle {
    fn name(&self) -> &str {
        "Rectangle"
    }
}

struct Triangle {
    base: f64,
    height: f64,
}

impl Shape for Triangle {
    fn area(&self) -> f64 {
        (self.base * self.height) / 2.0
    }
}

impl Colored for Triangle {
    fn color(&self) -> &str {
        "green"
    }
}

impl Named for Triangle {
    fn name(&self) -> &str {
        "Triangle"
    }
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

impl Colored for Circle {
    fn color(&self) -> &str {
        "blue"
    }
}

impl Named for Circle {
    fn name(&self) -> &str {
        "Circle"
    }
}

// Generic function with multiple trait bounds
fn describe<T: Colored + Named>(shape: &T) {
    println!("Shape: {}, Color: {}, Area: {:.2}", 
             shape.name(), shape.color(), shape.area());
}

// Static dispatch: compiler generates code for each concrete type
fn static_area<T: Shape>(shape: &T) -> f64 {
    shape.area()
}

// Dynamic dispatch: runtime vtable lookup
fn dynamic_area(shape: &dyn Shape) -> f64 {
    shape.area()
}

// Working with heterogeneous collections (requires trait objects)
fn print_all_areas(shapes: &[&dyn Shape]) {
    for (i, shape) in shapes.iter().enumerate() {
        println!("Shape {}: area = {:.2}", i + 1, shape.area());
    }
}

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    let triangle = Triangle {
        base: 8.0,
        height: 6.0,
    };

    let circle = Circle {
        radius: 3.0,
    };

    println!("=== Traits and Supertraits ===");
    describe(&rect);
    describe(&triangle);
    describe(&circle);

    println!("\n=== Static Dispatch ===");
    println!("Rectangle area: {:.2}", static_area(&rect));
    println!("Triangle area: {:.2}", static_area(&triangle));
    println!("Circle area: {:.2}", static_area(&circle));

    println!("\n=== Dynamic Dispatch ===");
    println!("Rectangle area: {:.2}", dynamic_area(&rect));
    println!("Triangle area: {:.2}", dynamic_area(&triangle));
    println!("Circle area: {:.2}", dynamic_area(&circle));

    println!("\n=== Heterogeneous Collection ===");
    let shapes: Vec<&dyn Shape> = vec![&rect, &triangle, &circle];
    print_all_areas(&shapes);

    println!("\n=== Key Takeaways ===");
    println!("✓ Traits enable polymorphism without inheritance");
    println!("✓ Supertraits are compile-time constraints");
    println!("✓ Static dispatch = fast, code duplication");
    println!("✓ Dynamic dispatch = flexible, runtime overhead");
}
