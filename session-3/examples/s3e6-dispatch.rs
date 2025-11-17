// Static vs Dynamic Dispatch
//
// Rust provides two ways to work with traits polymorphically:
//
// 1. Static Dispatch (Generics):
//    - Uses monomorphization: compiler generates separate code for each type
//    - Faster (no vtable lookup, can inline)
//    - Larger binary size (code duplication)
//    - Known at compile time
//
// 2. Dynamic Dispatch (Trait Objects):
//    - Uses vtables: runtime lookup of method implementations
//    - Slower (indirect function call)
//    - Smaller binary (single function)
//    - Allows heterogeneous collections
//
// This is similar to C++ templates vs virtual methods.
//
// Your task: Compare static and dynamic dispatch performance and use cases

#![allow(unused_variables)]
#![allow(dead_code)]

trait Shape {
    fn area(&self) -> f64;
    fn perimeter(&self) -> f64;
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
    
    fn perimeter(&self) -> f64 {
        2.0 * (self.width + self.height)
    }
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
    
    fn perimeter(&self) -> f64 {
        2.0 * std::f64::consts::PI * self.radius
    }
}

// Static dispatch: The compiler generates a different version of this function
// for each concrete type (Rectangle, Circle, etc.)
// Like C++ templates
fn static_area<T: Shape>(shape: &T) -> f64 {
    shape.area()
}

// Dynamic dispatch: Runtime vtable lookup to find the right implementation
// Like C++ virtual methods
// Note: &dyn Shape is a "trait object" - a fat pointer (pointer + vtable pointer)
fn dynamic_area(shape: &dyn Shape) -> f64 {
    shape.area()
}

// TODO: Write a function called `static_perimeter` that uses static dispatch
// to calculate the perimeter of any shape

// TODO: Write a function called `dynamic_perimeter` that uses dynamic dispatch
// to calculate the perimeter of any shape

// TODO: Write a function called `print_areas` that takes a slice of trait objects
// (&[&dyn Shape]) and prints the area of each shape
// This demonstrates why trait objects are useful: heterogeneous collections!
// You can't do this with generics alone.

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    let circle = Circle {
        radius: 3.0,
    };

    println!("=== Static Dispatch ===");
    println!("Rectangle area: {}", static_area(&rect));
    println!("Circle area: {}", static_area(&circle));
    
    // TODO: Call static_perimeter on both shapes

    println!("\n=== Dynamic Dispatch ===");
    println!("Rectangle area: {}", dynamic_area(&rect));
    println!("Circle area: {}", dynamic_area(&circle));
    
    // TODO: Call dynamic_perimeter on both shapes

    println!("\n=== Heterogeneous Collection (Dynamic Dispatch Only) ===");
    // This only works with trait objects!
    // With static dispatch, all items must be the same concrete type
    let shapes: Vec<&dyn Shape> = vec![&rect, &circle, &rect];
    
    // TODO: Use your print_areas function on the shapes vector
    
    // Try this: Can you create Vec<T: Shape> with different types? No!
    // let mixed: Vec<???> = vec![rect, circle]; // Won't compile!
    
    println!("\n=== Performance Considerations ===");
    println!("Static dispatch:");
    println!("  - Faster (no vtable lookup, can inline)");
    println!("  - Larger binary (monomorphization creates code for each type)");
    println!("  - Known at compile time");
    println!("\nDynamic dispatch:");
    println!("  - Slower (vtable lookup at runtime)");
    println!("  - Smaller binary (single function)");
    println!("  - Allows heterogeneous collections");
    println!("  - Enables runtime polymorphism");
}
