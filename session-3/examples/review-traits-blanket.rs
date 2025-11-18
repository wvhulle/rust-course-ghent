//! Instead of implementing our trait for each type individually,
//! we can implement it once for ALL types that meet certain criteria!

use std::fmt::{Debug, Display};

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

    name.print_boxed();
    count.print_boxed();
    price.print_boxed();
    flag.print_boxed();

    dbg!("All types work with ONE implementation!");
}

trait JsonFormat {
    fn to_json(&self) -> String;
}

impl<T: Display> JsonFormat for T {
    fn to_json(&self) -> String {
        todo!("Return {{\"value\": \"<self>\"}} using format! and Display")
    }
}

trait DebugLog {
    fn log(&self);
}

impl<T: Debug> DebugLog for T {
    fn log(&self) {
        todo!("Print [LOG] followed by the debug representation")
    }
}

trait CollectionStats {
    fn describe(&self);
}

impl<T: Display> CollectionStats for Vec<T> {
    fn describe(&self) {
        todo!("Print 'Vec with N items:' then list each item with '- '")
    }
}

trait DoubleDisplay {
    fn print_twice(&self);
}

impl<T> DoubleDisplay for T
where
    T: Display + Clone,
{
    fn print_twice(&self) {
        todo!("Print self twice, separated by ' | '")
    }
}

fn test_json_format() {
    todo!("Step 1: Implement the to_json method using format! and Display");

    todo!("Step 2: Create test values: 'hello', 42, 3.14, true");

    todo!("Step 3: Call to_json on each value and print using dbg!");
}

fn test_debug_log() {
    todo!("Step 1: Implement the log method using println! and Debug");

    todo!("Step 2: Create test values: vec![1, 2], (10, 'x'), Some(5), Ok::<_, ()>(42)");

    todo!("Step 3: Call log on each value");
}

fn test_collection_stats() {
    todo!("Step 1: Implement describe - print 'Vec with N items:' using self.len()");

    todo!("Step 2: Loop through items and print each with '- ' prefix");

    todo!("Step 3: Create vec![String::from('a'), String::from('b')] and call describe");

    todo!("Step 4: Create vec![1, 2, 3] and call describe");
}

fn test_multiple_bounds() {
    todo!("Step 1: Implement print_twice using println! to show self twice");

    todo!("Step 2: Test with String::from('Rust')");

    todo!("Step 3: Test with i32 value 42");
}

fn main() {
    demonstrate_blanket();

    test_json_format();

    test_debug_log();

    test_collection_stats();

    test_multiple_bounds();

    println!("Compare: how many impl blocks did you write vs review-traits-extension.rs?");
}
