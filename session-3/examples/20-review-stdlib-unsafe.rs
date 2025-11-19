//! Discover how Rust optimizes memory layout for Option

use std::mem::{size_of, transmute};
use std::num::NonZeroU32;

/// Compares the size of a type with its Option wrapper to detect niche optimization
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

/// Shows the raw bit representation of a value by transmuting to u8
macro_rules! show_bits {
    ($value:expr) => {
        println!("  {}: {:#x}", stringify!($value), unsafe {
            transmute::<_, u8>($value)
        });
    };
}

fn main() {
    println!("=== Surprising Discovery ===\n");

    compare_sizes!(bool);
    compare_sizes!(u8);

    println!("\nWhy is Option<bool> the same size as bool, but Option<u8> is larger?");
    println!("\n=== Investigating bool ===\n");

    show_bits!(false);
    show_bits!(true);
    show_bits!(None::<bool>);
    show_bits!(Some(false));
    show_bits!(Some(true));

    println!("\n=== Your Turn ===\n");

    // TODO: Use compare_sizes! to check: &i32, Box<i32>, NonZeroU32
    todo!("compare values");

    // TODO: Create show_option_ref_bits similar to show_option_bool_bits to investigate Option<&i32>
    todo!("handle Option");

    println!("\n=== Challenge: Custom Niche Type ===\n");

    enum Temperature {
        Celsius(i16),
        Fahrenheit(i16),
    }

    compare_sizes!(Temperature);

    // Temperature has niche values - can you create a UserId type that also gets optimized?
    // Hint: Use a wrapper around NonZeroU32 to get the niche optimization

    struct UserId(NonZeroU32);
    compare_sizes!(UserId);

    println!("\n=== Bonus: Nested Options ===\n");

    compare_sizes!(Option<bool>);
    compare_sizes!(Option<Option<bool>>);

    // TODO: Predict: what is size_of::<Option<Option<Option<bool>>>>()?
    todo!("handle Option");
}
