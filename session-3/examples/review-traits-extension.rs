//! Since we can't modify foreign traits, we create our own trait
//! and implement it for each type individually.

trait BoxedDisplay {
    fn print_boxed(&self);
}

impl BoxedDisplay for String {
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

fn try_with_more_types() {
    let price = 9.99;
    let flag = true;

    // Uncomment to see the problem:
    // price.print_boxed();
    // flag.print_boxed();
}

trait JsonFormat {
    fn to_json(&self) -> String;
}

impl JsonFormat for String {
    fn to_json(&self) -> String {
        todo!("Return {{\"value\": \"<self>\"}} using format!")
    }
}

impl JsonFormat for i32 {
    fn to_json(&self) -> String {
        todo!("Return {{\"value\": <self>}}")
    }
}

impl JsonFormat for bool {
    fn to_json(&self) -> String {
        todo!("Return {{\"value\": true}} or {{\"value\": false}}")
    }
}

trait Prefixed {
    fn with_prefix(&self, prefix: &str) -> String;
}

impl Prefixed for String {
    fn with_prefix(&self, prefix: &str) -> String {
        todo!("Return prefix + ': ' + self")
    }
}

impl Prefixed for i32 {
    fn with_prefix(&self, prefix: &str) -> String {
        todo!("Return prefix + ': ' + self (convert i32 to String)")
    }
}

fn main() {
    demonstrate_extension();

    todo!("Implement all JsonFormat methods, then test with String, i32, and bool values");

    todo!("Implement Prefixed methods, then call with_prefix on String and i32");

    todo!("Add BoxedDisplay for f64. Copy-paste the impl for i32 - notice the duplication?");

    todo!("Uncomment the lines in try_with_more_types(). What do you need to add?");

    todo!("Count how many times you wrote the same println! code in BoxedDisplay impls");

    dbg!("This works but doesn't scale!");
}
