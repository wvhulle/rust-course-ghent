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
        todo!("Return the new sum value")
    };

    println!("{}", add_to_sum(5));

    todo!("Call add_to_sum(3) and add_to_sum(10). You'll get a compile error - what's missing?");

    let next_id = 0;

    let id_gen = || {
        todo!(
            "Increment next_id and return it. You'll need to fix compilation errors about mutability"
        )
    };

    todo!("Call id_gen() three times and print each result. What do you need to mark as mut?");

    todo!("Pass id_gen to apply_three_times. Does it compile?");
}
