//! Inline assembly in Rust for low-level control
//!
//! You're writing performance-critical code or hardware interfaces

use std::arch::asm;

// Demonstrate: Simple inline assembly to increment a number
#[cfg(target_arch = "x86_64")]
fn asm_increment(value: u64) -> u64 {
    let mut result = value;
    unsafe {
        asm!(
            "add {0}, 1",
            inout(reg) result,
        );
    }
    result
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_increment(value: u64) -> u64 {
    value + 1
}

// Demonstrate: Reading a value with assembly
#[cfg(target_arch = "x86_64")]
fn asm_negate(value: i64) -> i64 {
    let result: i64;
    unsafe {
        asm!(
            "mov {result}, {input}",
            "neg {result}",
            input = in(reg) value,
            result = out(reg) result,
        );
    }
    result
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_negate(value: i64) -> i64 {
    -value
}

// Exercise: Write inline assembly to double a number
#[cfg(target_arch = "x86_64")]
fn asm_double(value: u64) -> u64 {
    todo!("Step 1: Create mutable result variable initialized to value");
    todo!("Step 2: Use asm! with 'add {{0}}, {{0}}' to double it");
    todo!("Step 3: Use inout(reg) since we're modifying the value");
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_double(value: u64) -> u64 {
    value * 2
}

// Exercise: Bitwise NOT operation
#[cfg(target_arch = "x86_64")]
fn asm_not(value: u64) -> u64 {
    todo!("Use 'not {{0}}' instruction with inout(reg)");
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_not(value: u64) -> u64 {
    !value
}

// Attempt 1: Try using asm without unsafe
// Uncomment to see the error:
//
// #[cfg(target_arch = "x86_64")]
// fn broken_no_unsafe(value: u64) -> u64 {
//     let mut result = value;
//     asm!(
//         "add {0}, 1",
//         inout(reg) result,
//     );
//     result
// }

// Attempt 2: Forget to mark result as mut
// Uncomment to see the error:
//
// #[cfg(target_arch = "x86_64")]
// fn broken_immutable(value: u64) -> u64 {
//     let result = value;
//     unsafe {
//         asm!(
//             "add {0}, 1",
//             inout(reg) result,
//         );
//     }
//     result
// }

fn main() {
    let value = 42;
    dbg!(asm_increment(value));

    let negative = -100;
    dbg!(asm_negate(negative));

    todo!("Uncomment Attempt 1 to see why unsafe is required for asm!");
    todo!("Uncomment Attempt 2 to see the mutability error");

    todo!("Implement asm_double");
    todo!("Test it with asm_double(21)");

    todo!("Implement asm_not");
    todo!("Test it with asm_not(0xFFFF_FFFF_0000_0000)");

    todo!("Research: Why is inline assembly unsafe?");
    todo!("Research: What x86_64 instructions are commonly used?");
}
