//! Extension traits let you add methods to existing types
//!
//! Notice the repetitive implementations - this motivates blanket impls

use std::fmt::Display;

// Demonstration: Adding a custom method to standard library types

// We create a new trait (without specifying any concrete type)
// The trait will function as an *extension trait*
trait BoxedDisplay {
    // This is the additional behaviour that we want to implement for foreign types.
    fn print_boxed(&self);
}

impl BoxedDisplay for String {
    // We implement the behaviour for a concrete type: strings.
    fn print_boxed(&self) {
        println!("╔══════════════════╗");
        println!("║ {:<16} ║", self);
        println!("╚══════════════════╝");
    }
}

impl BoxedDisplay for i32 {
    fn print_boxed(&self) {
        println!("╔══════════════════╗");
        println!("║ {:<16} ║", self);
        println!("╚══════════════════╝");
    }
}

fn demonstrate_extension() {
    let name = "Rust".to_string();
    let count = 42;

    name.print_boxed();
    count.print_boxed();
}

// Exercise: Add a method to double values

// Now do the same thing with a new behaviour for numbers, numbers that can be doubled.
trait Doubled {
    fn doubled(&self) -> Self;
}

impl Doubled for i32 {
    fn doubled(&self) -> Self {
        todo!("Return self * 2")
    }
}

impl Doubled for f64 {
    fn doubled(&self) -> Self {
        todo!("Return self * 2.0")
    }
}

fn main() {
    println!("=== Demonstration ===");
    demonstrate_extension();

    println!("\n=== Exercise: Doubled trait ===");
    todo!("Implement doubled() for i32 and f64");
    // let num = 21;
    // let pi = 3.14;
    // dbg!(num.doubled());
    // dbg!(pi.doubled());

    // In effect, your new trait "extends" the foreign data type.
    // That is why it is called an *extension trait*

    todo!("Implement BoxedDisplay for f64 and bool to make them compile");
}
