//! You're building a logging library and want to make all types loggable.
//! Let's see what Rust allows...

use std::fmt::Display;

// Your first implementation: a simple function that works
fn log_value<T: Display>(value: &T, level: &str) {
    println!("[{}] {}", level, value);
}

// Creating a generic method does not feel optimal. A better approach would be to do something that is more akin to conventional OOP classes interfaces.
//
// What happens when you add methods to the Display trait directly?
// (uncomment following code block)
//
// impl Display {
//     fn log_info(&self) {
//         println!("[INFO] {}", self);
//     }
// }
//
// Does this work? Can we just add methods to standard library traits?
// Indeed, everything in the standard library is *foreign*.

// You might have seen compiler messages in the previous attempt.
// What happens when you treat Display as a trait object with `dyn`?
// A trait object is more similar to a OOP class object.
//
// impl dyn Display {
//     fn log_info(&self) {
//         println!("[INFO] {}", self);
//     }
// }
//
// Why did you see the message that you saw?
// Putting `dyn` in front of a trait turns it into objects with dynamic method dispatch.
// However, they are still *foreign objects*, derived from *foreign traits*.
//
// IMPORTANT: Why do you think standard library traits are foreign?

// What happens if we try to implement a foreign trait for a foreign type?
// Yes, vectors are foreign, since they are std types.
//
// impl Display for Vec<i32> {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         write!(f, "{:?}", self)
//     }
// }

// Try it out yourself:

// Let's try implementing our own trait for a foreign type
trait Loggable {
    fn log_info(&self);
}

impl Loggable for String {
    fn log_info(&self) {
        println!("[INFO] {}", self);
    }
}

// Implement our trait for another type from std
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
    println!("Foreign trait + Foreign type = ❌");
    println!("Our trait + Foreign type = ✓");
    println!("Foreign trait + Our type = ✓");
}

fn main() {
    explore_orphan_rule();

    test_orphan_combinations();

    summarize_orphan_rule();
}
