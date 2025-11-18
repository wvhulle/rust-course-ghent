//! Inline assembly lets you write CPU instructions directly
//!
//! Syntax reference:
//! - `{0}`, `{name}` = placeholders for operands  
//! - `in(reg)` = read-only input
//! - `out(reg)` = write-only output
//! - `inout(reg)` = read and modify
//!
//! x86_64 instructions: add, sub, mov, neg, not

use std::arch::asm;

// Demonstrate: Basic assembly structure
#[cfg(target_arch = "x86_64")]
fn demonstrate_asm_increment(value: u64) -> u64 {
    let mut result = value;
    unsafe {
        asm!(
            "add {0}, 1",      // instruction: add 1 to register
            inout(reg) result, // in: read value, out: write result
        );
    }
    result
}

#[cfg(not(target_arch = "x86_64"))]
fn demonstrate_asm_increment(value: u64) -> u64 {
    value + 1
}

// Demonstrate: Multiple instructions with named operands
#[cfg(target_arch = "x86_64")]
fn demonstrate_asm_negate(value: i64) -> i64 {
    let result: i64;
    unsafe {
        asm!(
            "mov {result}, {input}", // copy input to result
            "neg {result}",          // negate (multiply by -1)
            input = in(reg) value,   // named input operand
            result = out(reg) result, // named output operand
        );
    }
    result
}

#[cfg(not(target_arch = "x86_64"))]
fn demonstrate_asm_negate(value: i64) -> i64 {
    -value
}

// Attempt 1: Try without unsafe block
// Uncomment to see why asm! requires unsafe:
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

// Attempt 2: Forget the mut keyword
// Uncomment to see the mutability error:
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

// Attempt 3: Use wrong operand direction
// Uncomment to discover in vs out vs inout:
//
// #[cfg(target_arch = "x86_64")]
// fn broken_wrong_direction(value: u64) -> u64 {
//     let mut result = value;
//     unsafe {
//         asm!(
//             "add {0}, 1",
//             in(reg) result,
//         );
//     }
//     result
// }

// Exercise 1: Double a number (add register to itself)
#[cfg(target_arch = "x86_64")]
fn asm_double(value: u64) -> u64 {
    todo!("Pattern from demonstrate_asm_increment, but use 'add {{0}}, {{0}}'");
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_double(value: u64) -> u64 {
    value * 2
}

// Exercise 2: Bitwise NOT (flip all bits)
#[cfg(target_arch = "x86_64")]
fn asm_not(value: u64) -> u64 {
    todo!("Same pattern, use instruction 'not {{0}}'");
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_not(value: u64) -> u64 {
    !value
}

// Exercise 3: Add two numbers (use named operands like demonstrate_asm_negate)
#[cfg(target_arch = "x86_64")]
fn asm_add(a: u64, b: u64) -> u64 {
    todo!("Two instructions: 'mov {{result}}, {{a}}' then 'add {{result}}, {{b}}'");
    todo!("Use named operands: a = in(reg) a, b = in(reg) b, result = out(reg) result");
}

fn main() {
    // Working examples
    dbg!(demonstrate_asm_increment(42));
    dbg!(demonstrate_asm_negate(-100));

    todo!("Uncomment broken_no_unsafe and read the compiler error");
    todo!("Uncomment broken_immutable - what's different about this error?");
    todo!("Uncomment broken_wrong_direction - compare with broken_immutable");

    todo!("Implement asm_double to double 21 -> expect 42");
    // dbg!(asm_double(21));

    todo!("Implement asm_not to flip bits of 0xFFFF_FFFF_0000_0000");
    // dbg!(asm_not(0xFFFF_FFFF_0000_0000));

    todo!("Implement asm_add to compute 25 + 17");
    // dbg!(asm_add(25, 17));

    // Pattern discovered: asm! must be unsafe, variables modified with inout must be mut
}
