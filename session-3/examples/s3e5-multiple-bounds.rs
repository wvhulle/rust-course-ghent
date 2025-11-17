// Multiple Trait Bounds
//
// Generic functions can require that a type implements multiple traits.
// This is similar to C++ concepts or template constraints.
//
// Syntax options:
// 1. fn func<T: Trait1 + Trait2>(param: &T)
// 2. fn func<T>(param: &T) where T: Trait1 + Trait2
//
// Your task: Write generic functions that work with multiple trait bounds

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

// Example: Function requiring both Colored and Named
// Note: Since both Colored and Named require Shape, we get Shape for free!
fn describe<T: Colored + Named>(shape: &T) {
    println!("Shape: {}, Color: {}, Area: {:.2}", 
             shape.name(), shape.color(), shape.area());
}

// TODO: Write a function called `compare_areas` that takes two parameters,
// both of which must implement Shape. It should print which one is larger.
// Signature: fn compare_areas<T: Shape, U: Shape>(a: &T, b: &U)

// TODO: Write a function called `describe_colored` that takes a parameter
// implementing Colored and prints: "This <color> shape has area <area>"
// Hint: You only need Colored, not Named

// TODO: Write a function called `full_description` using the 'where' syntax
// that takes a parameter implementing all three traits: Shape, Colored, and Named
// Print all available information about the shape
// Signature: fn full_description<T>(shape: &T) where T: Shape + Colored + Named

// TODO: Write a function called `area_sum` that takes two shapes and returns
// the sum of their areas. Use the + operator syntax for trait bounds.

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    let circle = Circle {
        radius: 3.0,
    };

    println!("=== Using describe ===");
    describe(&rect);
    describe(&circle);

    // TODO: Use compare_areas to compare rect and circle
    
    // TODO: Use describe_colored on rect and circle
    
    // TODO: Use full_description on rect and circle
    
    // TODO: Print the sum of areas using area_sum
    
    // Question: What's the difference between the two trait bound syntaxes?
    // Answer: T: Trait1 + Trait2 is more concise for simple cases
    //         where T: Trait1 + Trait2 is clearer when you have multiple parameters or complex bounds
}
