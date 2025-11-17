// Supertraits - Trait Bounds on Traits
//
// A supertrait is a trait that another trait depends on.
// Syntax: trait SubTrait: SuperTrait { ... }
//
// Key differences from C++ inheritance:
// 1. Traits don't contain data - no field inheritance
// 2. Supertraits are compile-time constraints, not runtime base classes
// 3. No diamond problem with data duplication
// 4. No virtual inheritance needed
//
// When you implement a trait with a supertrait, you must also implement
// the supertrait for that type.
//
// Your task: Implement traits with supertrait constraints

#![allow(unused_variables)]
#![allow(dead_code)]

trait Shape {
    fn area(&self) -> f64;
}

// Supertrait: Colored requires Shape to be implemented
// This means: "Any type implementing Colored must also implement Shape"
trait Colored: Shape {
    fn color(&self) -> &str;
}

// Another supertrait with the same constraint
trait Named: Shape {
    fn name(&self) -> &str;
}

struct Rectangle {
    width: f64,
    height: f64,
}

// We implement Shape first (required by both Colored and Named)
impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

// Now we can implement Colored (because Shape is already implemented)
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

// TODO: Define a struct called `Circle` with field:
// - radius: f64

// TODO: Implement Shape for Circle
// Area formula: π * radius²

// TODO: Implement Colored for Circle (choose any color)

// TODO: Implement Named for Circle

// TODO: Define a struct called `Triangle` with fields:
// - base: f64
// - height: f64

// TODO: Implement Shape for Triangle
// Area formula: (base * height) / 2.0

// TODO: Implement only Colored for Triangle (not Named)
// This demonstrates that you can implement some supertraits but not others

fn main() {
    let rect = Rectangle {
        width: 10.0,
        height: 5.0,
    };

    println!("Shape: {}, Color: {}, Area: {}", 
             rect.name(), rect.color(), rect.area());

    // TODO: Create a Circle and print its name, color, and area
    
    // TODO: Create a Triangle and print its color and area
    // Note: Triangle doesn't implement Named, so you can't call .name() on it
    
    // Question: What happens if you try to implement Colored without implementing Shape?
    // Try commenting out the Shape implementation for one of your types and see!
}
