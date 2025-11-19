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

#[cfg(target_arch = "x86_64")]
fn asm_double(value: u64) -> u64 {
    // TODO: Follow pattern from demonstrate_asm_increment
    // TODO: Use instruction 'add {0}, {0}' to add register to itself
    todo!("return self")
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_double(value: u64) -> u64 {
    value * 2
}

#[cfg(target_arch = "x86_64")]
fn asm_not(value: u64) -> u64 {
    // TODO: Same pattern as asm_double
    // TODO: Use instruction 'not {0}' to flip all bits
    todo!("asm block")
}

#[cfg(not(target_arch = "x86_64"))]
fn asm_not(value: u64) -> u64 {
    !value
}

#[cfg(target_arch = "x86_64")]
fn asm_add(a: u64, b: u64) -> u64 {
    // TODO: Follow pattern from demonstrate_asm_negate with named operands
    // TODO: Use 'mov {result}, {a}' then 'add {result}, {b}'
    // TODO: Name operands: a = in(reg) a, b = in(reg) b, result = out(reg) result
    todo!("handle Result")
}

fn main() {
    dbg!(demonstrate_asm_increment(42));
    dbg!(demonstrate_asm_negate(-100));

    // TODO: Uncomment broken_no_unsafe and read the error
    // TODO: Uncomment broken_immutable - compare the error
    // TODO: Uncomment broken_wrong_direction - see the difference

    // TODO: Implement asm_double to double 21 -> expect 42
    // dbg!(asm_double(21));

    // TODO: Implement asm_not to flip bits of 0xFFFF_FFFF_0000_0000
    // dbg!(asm_not(0xFFFF_FFFF_0000_0000));

    // TODO: Implement asm_add to compute 25 + 17
    // dbg!(asm_add(25, 17));
}
