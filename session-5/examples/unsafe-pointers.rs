//! What happens when you dereference raw pointers incorrectly?
//!
//! Run: `cargo run --example unsafe-pointers`
//! Test: `cargo test --example unsafe-pointers`
//!
//! Note: Tests will fail until you complete the TODO items.

// Working example - safe raw pointer usage
fn demonstrate_safe_pointers() {
    let mut x = 10;
    let p1: *mut i32 = &raw mut x;
    let p2 = p1 as *const i32;

    // SAFETY: p1 and p2 point to a local variable that lives for this scope,
    // and no references exist while we use the raw pointers.
    unsafe {
        dbg!(*p1);
        *p1 = 6;
        dbg!(*p2);
    }
}

// Attempt 1: Creating a reference from a raw pointer while modifying the original
// Uncomment to see what happens:
//
// fn attempt_aliasing() {
//     let mut x = 10;
//     let p1: *mut i32 = &raw mut x;
//     let r: &i32 = unsafe { &*p1 };
//     dbg!(r);
//     x = 50;  // Mutate through original binding
//     dbg!(r); // UB: reference observes mutation it shouldn't see
// }

// Attempt 2: Using a dangling pointer
// Uncomment to see what happens (may crash or produce garbage):
//
// fn attempt_dangling() -> *const i32 {
//     let x = 42;
//     &raw const x  // Returns pointer to stack variable that will be deallocated
// }

fn swap_via_pointers(a: &mut i32, b: &mut i32) {
    // TODO: Create raw mutable pointers using &raw mut a and &raw mut b
    // TODO: Use unsafe block to read/write through pointers to swap values
    // SAFETY: a and b are valid, aligned, non-overlapping mutable references
    let _ = (a, b);
}

fn sum_with_pointer_arithmetic(arr: &[i32]) -> i32 {
    if arr.is_empty() {
        return 0;
    }
    // TODO: Get raw const pointer using arr.as_ptr()
    // TODO: Loop through indices, use ptr.add(i) inside unsafe to access elements
    // SAFETY: indices stay within bounds, pointer derived from valid slice
    let _ = arr;
    0
}

fn find_max_ptr<'a>(data: &'a [i32]) -> Option<&'a i32> {
    if data.is_empty() {
        return None;
    }
    // TODO: Track max_ptr starting at data.as_ptr()
    // TODO: Loop through, compare *current_ptr with *max_ptr, update if larger
    // TODO: Convert max_ptr back to &i32 using unsafe { &*max_ptr }
    // SAFETY: pointers point to valid elements within slice lifetime 'a
    let _ = data;
    None
}

fn write_value(ptr: *mut i32, value: i32) {
    // TODO: Write a SAFETY comment explaining what the caller must guarantee:
    // - ptr must be non-null
    // - ptr must be properly aligned
    // - ptr must point to valid, initialized memory
    // - no other references to the memory may exist
    unsafe {
        *ptr = value;
    }
}

fn main() {
    demonstrate_safe_pointers();

    // TODO: Uncomment attempt_aliasing() and run with miri to detect UB
    // TODO: Uncomment attempt_dangling() and observe the returned pointer

    // Test swap
    let mut x = 5;
    let mut y = 10;
    swap_via_pointers(&mut x, &mut y);
    dbg!(x, y);

    // Test sum
    dbg!(sum_with_pointer_arithmetic(&[1, 2, 3, 4, 5]));

    // Test find_max
    dbg!(find_max_ptr(&[1, 5, 3, 2]));

    // Test write_value
    let mut z = 0;
    write_value(&mut z, 42);
    dbg!(z);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_swap() {
        let mut x = 5;
        let mut y = 10;
        swap_via_pointers(&mut x, &mut y);
        assert_eq!(x, 10);
        assert_eq!(y, 5);
    }

    #[test]
    fn test_sum() {
        assert_eq!(sum_with_pointer_arithmetic(&[1, 2, 3, 4, 5]), 15);
        assert_eq!(sum_with_pointer_arithmetic(&[]), 0);
        assert_eq!(sum_with_pointer_arithmetic(&[-1, 1]), 0);
    }

    #[test]
    fn test_find_max() {
        assert_eq!(find_max_ptr(&[1, 5, 3, 2]), Some(&5));
        assert_eq!(find_max_ptr(&[42]), Some(&42));
        assert_eq!(find_max_ptr(&[]), None);
    }

    #[test]
    fn test_write() {
        let mut x = 0;
        let ptr: *mut i32 = &mut x;
        write_value(ptr, 42);
        assert_eq!(x, 42);
    }
}
