//! When to use LazyLock and when not to

use std::sync::LazyLock;

// Valid use: Global static with expensive initialization
static COMPILED_REGEX: LazyLock<regex::Regex> = LazyLock::new(|| {
    println!("Compiling regex (happens once, on first use)");
    regex::Regex::new(r"\d{4}-\d{2}-\d{2}").unwrap()
});

fn demonstrate_valid_use() {
    dbg!(COMPILED_REGEX.is_match("2025-11-18"));
    dbg!(COMPILED_REGEX.is_match("invalid"));
}

// Attempt 1: Using LazyLock for simple formatting
//
// static CONFIG: LazyLock<String> = LazyLock::new(|| {
//     format!("app_v{}", env!("CARGO_PKG_VERSION"))
// });
//
// fn get_config_wrong() -> &'static str {
//     &CONFIG
// }

const fn get_config_better() -> &'static str {
    env!("CARGO_PKG_VERSION")
}

fn get_config_runtime() -> String {
    format!("app_v{}", env!("CARGO_PKG_VERSION"))
}

// Attempt 2: Using LazyLock for local state
//
// fn process_items(items: &[i32]) {
//     static CACHE: LazyLock<Vec<i32>> = LazyLock::new(|| Vec::new());
// }

fn process_items_better(items: &[i32]) -> Vec<i32> {
    let mut cache = Vec::new();
    todo!("Process items and populate cache")
}

// Valid use: Global configuration from runtime values
static DB_URL: LazyLock<String> = LazyLock::new(|| {
    std::env::var("DATABASE_URL").unwrap_or_else(|_| "sqlite::memory:".to_string())
});

fn demonstrate_runtime_config() {
    dbg!(&*DB_URL);
}

// Attempt 3: Using LazyLock for mutable state
//
// static mut COUNTER: LazyLock<i32> = LazyLock::new(|| 0);
//
// fn increment_counter() {
//     unsafe {
//         *COUNTER += 1;
//     }
// }

fn create_counter() -> impl FnMut() -> i32 {
    todo!("Step 1: Create a closure that captures a mutable counter");
    todo!("Step 2: Each call should increment and return the new value");
    todo!("Hint: Don't use LazyLock for this - use a closure with mutable capture");
}

fn main() {
    demonstrate_valid_use();

    dbg!(get_config_better());
    dbg!(get_config_runtime());

    demonstrate_runtime_config();

    todo!("Uncomment Attempt 1 - Is LazyLock needed for simple formatting?");
    todo!("Uncomment Attempt 2 - Should you use LazyLock for local state?");
    todo!("Uncomment Attempt 3 - Can LazyLock be mutable?");

    let items = [1, 2, 3, 4, 5];
    dbg!(process_items_better(&items));

    let mut counter = create_counter();
    dbg!(counter());
    dbg!(counter());
    dbg!(counter());

    // Use LazyLock for: expensive global initialization, runtime config in statics
    // Don't use for: simple values, local state, mutable state, things that can be const
}
