//! Blanket implementations solve the repetition from extension traits
//!
//! ONE implementation for ALL types that implement Display or Debug

use std::fmt::Display;

// Compare with previous exercise - this single impl replaces all the individual ones
trait BoxedDisplay {
    fn print_boxed(&self);
}

impl<T: Display> BoxedDisplay for T {
    fn print_boxed(&self) {
        println!("╔══════════════════╗");
        println!("║ {:<16} ║", self);
        println!("╚══════════════════╝");
    }
}

fn demonstrate_blanket() {
    let name = "Rust".to_string();
    let count = 42;
    let price = 9.99;
    let flag = true;

    // All these types implement Display, so they all get print_boxed() for free!
    name.print_boxed();
    count.print_boxed();
    price.print_boxed();
    flag.print_boxed();
}

// Attempt: Try implementing without blanket impl
// Uncomment to see how much code you'd need:
//
// trait Repeated {
//     fn repeat(&self, times: usize);
// }
//
// impl Repeated for String {
//     fn repeat(&self, times: usize) {
//         for _ in 0..times {
//             print!("{} ", self);
//         }
//         println!();
//     }
// }
//
// impl Repeated for i32 {
//     fn repeat(&self, times: usize) {
//         for _ in 0..times {
//             print!("{} ", self);
//         }
//         println!();
//     }
// }
//
// impl Repeated for f64 {
//     fn repeat(&self, times: usize) {
//         for _ in 0..times {
//             print!("{} ", self);
//         }
//         println!();
//     }
// }

// Better: Single blanket implementation
trait Repeated {
    fn repeat(&self, times: usize);
}

impl<T: Display> Repeated for T {
    fn repeat(&self, times: usize) {
        for _ in 0..times {
            print!("{} ", self);
        }
        println!();
    }
}

// Exercise: Create a blanket impl for the Labeled trait from previous exercise
trait Labeled {
    fn with_label(&self, label: &str) -> String;
}

impl<T> Labeled for T {
    fn with_label(&self, label: &str) -> String {
        todo!("Add trait bound T: Display to the impl line above");
        todo!("Use format! to return 'label: self'");
    }
}

// Exercise: Create a blanket impl for doubling displayable values
trait Doubled {
    fn doubled_display(&self) -> String;
}

impl<T> Doubled for T {
    fn doubled_display(&self) -> String {
        todo!("Add trait bound T: Display");
        todo!("Return format!('{} {}', self, self)");
    }
}

// Exercise: Implement for Vec<T> where T implements Display
trait BulletList {
    fn print_bullets(&self);
}

impl<T> BulletList for Vec<T> {
    fn print_bullets(&self) {
        todo!("Add trait bound T: Display to impl");
        todo!("Loop through self and println!('- {}', item) for each");
    }
}

// Exercise: Multiple bounds with where clause
trait Inspectable {
    fn inspect(&self) -> String;
}

impl<T> Inspectable for T {
    fn inspect(&self) -> String {
        todo!("Add where clause: T: Display + Clone");
        todo!("Clone self, then return format!('Value: {}', cloned)");
    }
}

fn main() {
    println!("=== Blanket impl demonstration ===");
    demonstrate_blanket();

    println!("\n=== Repeated trait ===");
    "Rust".repeat(3);
    42.repeat(5);
    3.14.repeat(2);
    dbg!("One impl, works for all Display types!");

    println!("\n=== Exercise: Labeled trait ===");
    todo!("Implement blanket impl for Labeled");
    // dbg!(42.with_label("Answer"));
    // dbg!("Rust".with_label("Language"));
    // dbg!(true.with_label("Flag"));

    println!("\n=== Exercise: Doubled trait ===");
    todo!("Implement blanket impl for Doubled");
    // dbg!(21.doubled_display());
    // dbg!("Echo".doubled_display());

    println!("\n=== Exercise: BulletList for Vec ===");
    todo!("Implement blanket impl for BulletList");
    // let languages = vec!["Rust", "Python", "Go"];
    // languages.print_bullets();
    // let numbers = vec![1, 2, 3, 4, 5];
    // numbers.print_bullets();

    println!("\n=== Exercise: Multiple bounds ===");
    todo!("Implement blanket impl for Inspectable with where clause");
    // dbg!(100.inspect());
    // dbg!("test".inspect());

    todo!("Uncomment the manual Repeated implementations above");
    todo!("Compare the 3 manual impls vs the 1 blanket impl - how much code saved?");

    dbg!("Blanket impls + extension traits = powerful pattern!");
}
