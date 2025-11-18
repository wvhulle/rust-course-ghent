//! You're building a logging library and want to make all types loggable.
//! Let's see what Rust allows...

use std::fmt::Display;

// Your first implementation: a simple function that works
fn log_value<T: Display>(value: &T, level: &str) {
    println!("[{}] {}", level, value);
}

// Attempt 1: Add methods to the Display trait
//
// impl Display {
//     fn log_info(&self) {
//         println!("[INFO] {}", self);
//     }
// }

// Attempt 2: Add methods to trait objects
//
// impl dyn Display {
//     fn log_info(&self) {
//         println!("[INFO] {}", self);
//     }
// }

// Attempt 3: Implement Display for a type we don't own
//
// impl Display for Vec<i32> {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         write!(f, "{:?}", self)
//     }
// }

// Let's try implementing our own trait for a foreign type
trait Loggable {
    fn log_info(&self);
}

impl Loggable for String {
    fn log_info(&self) {
        println!("[INFO] {}", self);
    }
}

// Attempt 4: Implement our trait for another type from std
// Uncomment to see:
//
// impl Loggable for Vec<i32> {
//     fn log_info(&self) {
//         println!("[INFO] {:?}", self);
//     }
// }

// Attempt 5: Implement a foreign trait for our type
struct MyLogger {
    prefix: String,
}

// Uncomment to try:
//
// impl Display for MyLogger {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         write!(f, "[{}]", self.prefix)
//     }
// }

fn explore_orphan_rule() {
    let message = "Hello, Rust!".to_string();

    log_value(&message, "DEBUG");

    message.log_info();
}

fn test_orphan_combinations() {
    todo!("Uncomment Attempt 1. Does it compile? Read the error carefully");

    todo!("Uncomment Attempt 2. Does it compile? What's the error?");

    todo!("Uncomment Attempt 3. Does it compile? Why or why not?");

    todo!("Uncomment Attempt 4. Does it compile? Compare with Attempt 3");

    todo!("Uncomment Attempt 5. Does it compile? What's different from Attempt 3?");
}

fn summarize_orphan_rule() {
    dbg!("Foreign trait + Foreign type = ❌");
    dbg!("Our trait + Foreign type = ✓");
    dbg!("Foreign trait + Our type = ✓");
}

fn main() {
    explore_orphan_rule();

    test_orphan_combinations();

    summarize_orphan_rule();
}
