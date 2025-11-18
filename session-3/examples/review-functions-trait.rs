//! Learn how to accept closures as parameters using trait bounds

fn call_twice<F>(f: F) -> (String, String)
where
    F: Fn() -> String,
{
    let first = f();
    let second = f();
    (first, second)
}

fn apply_to_each<F>(_numbers: &[i32], _f: F) -> Vec<i32> {
    todo!(
        "Apply f to each number and collect results. Hint: You need a trait bound that allows calling f multiple times"
    )
}

fn transform_with<F>(_value: i32, _operation: F) -> i32 {
    todo!("Apply operation to value and return the result. Add appropriate trait bounds")
}

fn main() {
    let prefix = "Hello";
    let greeter = || format!("{}, World!", prefix);

    let (first, second) = call_twice(greeter);
    dbg!(first, second);
    dbg!(prefix);

    let numbers = [1, 2, 3, 4, 5];

    todo!("Implement apply_to_each, then use it with a closure that doubles each number");

    todo!("Use apply_to_each with a closure that captures a variable and adds it to each number");

    todo!("Implement transform_with, then call it with a closure that adds 10 to a number");

    todo!(
        "Try creating a closure that modifies a captured mutable variable. Can you use it with these functions?"
    );
}
