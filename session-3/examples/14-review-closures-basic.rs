//! Capturing Variables in Closures

fn apply_twice<F>(f: F) -> i32
where
    F: Fn(i32) -> i32,
{
    f(5) + f(10)
}

fn main() {
    let add_one = |x| x + 1;
    let result = apply_twice(add_one);
    dbg!(result);

    let multiplier = 3;
    let scale = |x| x * multiplier;
    let result = apply_twice(scale);
    dbg!(result);
    dbg!(multiplier);

    let offset = 10;

    // TODO: Add offset to x and return the result
    let add_offset = |_x| todo!("add offset");

    let result = apply_twice(add_offset);
    dbg!(result);

    let base = 5;
    let factor = 2;

    let complex = |x: i32| {
        // TODO: Use both base and factor in a calculation with x
        // TODO: For example: (x + base) * factor
        todo!("use both")
    };

    // TODO: Call apply_twice with complex and print the result using dbg!

    // TODO: Print base and factor using dbg! to verify they are still accessible
}
