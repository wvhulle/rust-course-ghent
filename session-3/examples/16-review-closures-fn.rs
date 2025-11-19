//! Accepting closures with Fn trait bounds and returning closures
//!
//! You're building a data processing library with flexible operations

// Demonstrate: Function that accepts Fn closure
fn call_twice<F>(f: F) -> (String, String)
where
    F: Fn() -> String,
{
    let first = f();
    let second = f();
    (first, second)
}

// Demonstrate: Returning closures with impl Fn
fn make_greeter(prefix: &str) -> impl Fn(&str) -> String + '_ {
    move |name| format!("{}, {}!", prefix, name)
}

// Exercise: Accept closure with trait bound
fn apply_to_each<F>(_numbers: &[i32], _f: F) -> Vec<i32> {
    // TODO: Add 'where F: Fn(i32) -> i32' trait bound to the function
    // TODO: Use .iter(), .map() with f, and .collect()
    todo!("use iter")
}

// Attempt 1: Try returning Fn without impl
// Uncomment to see the error:
//
// fn broken_make_adder(n: i32) -> Fn(i32) -> i32 {
//     |x| x + n
// }

// Exercise: Return a closure
fn make_multiplier(_factor: i32) -> impl Fn(i32) -> i32 {
    // TODO: Return a closure that multiplies its parameter by factor
    // TODO: Use 'move' keyword to capture factor by value
    todo!("capture var")
}
// Note: the previous is equivalent to:
// fn make_multiplier<F>(_factor: i32) -> F
// where
//     F: Fn(i32) -> i32,
// { ... }

// Exercise: Closure that takes multiple parameters
fn combine_values<F>(_x: i32, _y: i32, _combiner: F) -> i32
where
    F: Fn(i32, i32) -> i32,
{
    // TODO: Call combiner with x and y, return the result
    todo!("handle Result")
}

// Attempt 2: Try using fn pointer when you need Fn trait
// Uncomment to see what happens:
//
// fn use_fn_pointer(numbers: &[i32], f: fn(i32) -> i32) -> Vec<i32> {
//     let captured = 10;
//     let add_captured = |x| x + captured;
//     apply_to_each(numbers, add_captured)  // Won't work!
// }
//
// Why does this not work? What does Fn have that fn pointers don't have?

fn main() {
    let prefix = "Hello";
    let greeter = || format!("{}, World!", prefix);

    let (first, second) = call_twice(greeter);
    dbg!(first, second);
    dbg!(prefix);

    let greet = make_greeter("Welcome");
    dbg!(greet("Alice"));
    dbg!(greet("Bob"));

    // TODO: Uncomment Attempt 1 to see why you need impl Fn
    // TODO: Uncomment Attempt 2 to see fn pointer vs Fn trait difference

    let numbers = [1, 2, 3, 4, 5];

    // TODO: Implement apply_to_each, then use it with a closure that doubles each number

    // TODO: Use apply_to_each with a closure that captures a variable and adds it to each number

    // TODO: Implement make_multiplier to return a closure that multiplies by 5
    // TODO: Call the returned multiplier with 10 and use dbg!

    // TODO: Implement combine_values, then call it with 8, 4, and a division closure

    // TODO: Create a closure that modifies a captured mutable variable
    // TODO: Try to use it with call_twice. Does it compile? Why not?
}
