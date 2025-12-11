//! FnMut closures can mutate captured variables.

fn apply_three_times<F>(mut f: F)
where
    F: FnMut(),
{
    f();
    f();
    f();
}

fn main() {
    let mut counter = 0;
    let mut increment = || {
        counter += 1;
        println!("Counter: {}", counter);
    };

    increment();
    increment();
    println!("Final counter: {}", counter);

    let mut sum = 0;

    let add_to_sum = |x: i32| {
        sum += x;
        // TODO: Return the new sum value
        todo!("return value")
    };

    println!("{}", add_to_sum(5));

    // TODO: Call add_to_sum(3) and add_to_sum(10)
    // TODO: You'll get a compile error - what's missing?

    let next_id = 0;

    let id_gen = || {
        // TODO: Increment next_id and return it
        // TODO: You'll need to fix compilation errors about mutability
        todo!("handle Result")
    };

    // TODO: Call id_gen() three times and print each result
    // TODO: What do you need to mark as mut?

    // TODO: Pass id_gen to apply_three_times. Does it compile?
}
