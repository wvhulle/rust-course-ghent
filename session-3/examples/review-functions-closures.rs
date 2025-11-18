//! Closures Exercise
//!
//! Learn how to create and pass closures as function parameters

fn apply_operation<F>(_x: i32, _y: i32, _op: F) -> i32
where
    F: Fn(i32, i32) -> i32,
{
    todo!("Apply the operation closure to x and y")
}

fn filter_numbers<F>(_numbers: &[i32], _predicate: F) -> Vec<i32>
where
    F: Fn(&i32) -> bool,
{
    todo!("Return a new Vec containing only numbers where predicate returns true")
}

fn transform_strings<F>(_strings: &[&str], _transformer: F) -> Vec<String>
where
    F: Fn(&str) -> String,
{
    todo!("Apply transformer to each string and collect results")
}

fn main() {
    todo!("Create a closure that adds two numbers and pass it to apply_operation");

    todo!("Create a closure that checks if a number is even and pass it to filter_numbers with vec![1, 2, 3, 4, 5, 6]");

    todo!("Create a closure that converts strings to uppercase and pass it to transform_strings with vec![\"hello\", \"world\"]");

    todo!("Create a closure that multiplies two numbers by capturing a variable from the environment");
}
