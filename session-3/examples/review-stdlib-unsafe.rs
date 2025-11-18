//! Discover how Rust optimizes memory layout for Option

use std::mem::{size_of, transmute};

macro_rules! compare_sizes {
    ($t:ty) => {
        println!(
            "{}: {} bytes, Option<{}>: {} bytes",
            stringify!($t),
            size_of::<$t>(),
            stringify!($t),
            size_of::<Option<$t>>()
        );
    };
}

fn show_bool_bits(value: bool, label: &str) {
    unsafe {
        println!("  {}: {:#x}", label, transmute::<bool, u8>(value));
    }
}

fn show_option_bool_bits(value: Option<bool>, label: &str) {
    unsafe {
        println!("  {}: {:#x}", label, transmute::<Option<bool>, u8>(value));
    }
}

fn main() {
    println!("=== Surprising Discovery ===\n");

    compare_sizes!(bool);
    compare_sizes!(u8);

    println!("\nWhy is Option<bool> the same size as bool, but Option<u8> is larger?");
    println!("\n=== Investigating bool ===\n");

    show_bool_bits(false, "false");
    show_bool_bits(true, "true");
    show_option_bool_bits(None, "None::<bool>");
    show_option_bool_bits(Some(false), "Some(false)");
    show_option_bool_bits(Some(true), "Some(true)");

    println!("\n=== Your Turn ===\n");

    todo!("Use compare_sizes! to check: &i32, Box<i32>, NonZeroU32");

    todo!(
        "Create show_option_ref_bits similar to show_option_bool_bits to investigate Option<&i32>"
    );

    println!("\n=== Challenge: Custom Niche Type ===\n");

    enum Temperature {
        Celsius(i16),
        Fahrenheit(i16),
    }

    compare_sizes!(Temperature);

    todo!(
        "Can you create an enum that has the same size as Option<YourEnum>? Hint: use all possible values"
    );

    println!("\n=== Bonus: Nested Options ===\n");

    compare_sizes!(Option<bool>);
    compare_sizes!(Option<Option<bool>>);

    todo!("Predict: what is size_of::<Option<Option<Option<bool>>>>()?");
}
