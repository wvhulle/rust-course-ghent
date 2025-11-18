//! Learn the most commonly used Option methods

fn demonstrate_basics() {
    let some_value = Some(42);
    let none_value: Option<i32> = None;

    dbg!(some_value.is_some());
    dbg!(none_value.is_none());

    dbg!(some_value.unwrap_or(0));
    dbg!(none_value.unwrap_or(0));

    dbg!(some_value.map(|x| x * 2));
}

fn greet_user(name: Option<&str>) -> String {
    todo!("Use map to create 'Hello, NAME!' or unwrap_or to return 'Hello, Guest!'")
}

fn apply_discount(price: Option<i32>) -> Option<i32> {
    todo!("Use map to apply 10% discount (multiply by 0.9 as f64, then convert back)")
}

fn count_some_values(values: &[Option<i32>]) -> usize {
    todo!("Count how many Some values are in the slice using iter() and filter()")
}

fn main() {
    demonstrate_basics();
    println!();

    dbg!(greet_user(Some("Alice")));
    dbg!(greet_user(None));

    dbg!(apply_discount(Some(100)));
    dbg!(apply_discount(None));

    let values = [Some(1), None, Some(3), None, Some(5)];
    dbg!(count_some_values(&values));
}
