//! Master the Option type and its methods
//!
//! Progress from basic to advanced combinators

// Basic operations: is_some, is_none, unwrap_or, map
fn demonstrate_basics() {
    let some_value = Some(42);
    let none_value: Option<i32> = None;

    dbg!(some_value.is_some());
    dbg!(none_value.is_none());

    dbg!(some_value.unwrap_or(0));
    dbg!(none_value.unwrap_or(0));

    dbg!(some_value.map(|x| x * 2));
}

// Advanced operations: and_then, filter, or_else
fn demonstrate_advanced() {
    let some_value = Some(42);

    let result = some_value.and_then(|x| if x > 0 { Some(x * 2) } else { None });
    dbg!(result);

    let positive = some_value.filter(|&x| x > 0);
    dbg!(positive);

    let none: Option<i32> = None;
    let alternative = none.or_else(|| Some(100));
    dbg!(alternative);
}

// Basic exercises
fn greet_user(name: Option<&str>) -> String {
    todo!("Use map to create 'Hello, NAME!' or unwrap_or to return 'Hello, Guest!'")
}

fn apply_discount(price: Option<i32>) -> Option<i32> {
    todo!("Use map to apply 10% discount (multiply by 0.9 as f64, then convert back)")
}

fn count_some_values(values: &[Option<i32>]) -> usize {
    todo!("Count how many Some values are in the slice using iter() and filter()")
}

// Advanced exercises
fn safe_divide(numerator: i32, denominator: i32) -> Option<i32> {
    todo!("Return Some(numerator / denominator) if denominator != 0, otherwise None")
}

fn chain_divide(start: i32, divisor1: i32, divisor2: i32) -> Option<i32> {
    todo!("Use and_then to divide start by divisor1, then divide that result by divisor2")
}

fn get_voting_age(age: Option<u32>) -> Option<u32> {
    todo!("Use filter to return the age only if it's >= 18, otherwise None")
}

fn get_config_or_default(config: Option<String>) -> String {
    todo!(
        "Use or_else to return config if Some, or fetch from environment using \
         std::env::var(\"CONFIG\").ok()"
    )
}

fn sum_nested_options(values: Vec<Option<Option<i32>>>) -> i32 {
    todo!("Use filter_map and flatten to extract all values and sum them")
}

fn main() {
    println!("=== Basic Option operations ===");
    demonstrate_basics();

    println!("\n=== Basic exercises ===");
    todo!("Implement greet_user");
    // dbg!(greet_user(Some("Alice")));
    // dbg!(greet_user(None));

    todo!("Implement apply_discount");
    // dbg!(apply_discount(Some(100)));
    // dbg!(apply_discount(None));

    todo!("Implement count_some_values");
    // let values = [Some(1), None, Some(3), None, Some(5)];
    // dbg!(count_some_values(&values));

    println!("\n=== Advanced Option operations ===");
    demonstrate_advanced();

    println!("\n=== Advanced exercises ===");
    todo!("Implement safe_divide");
    // dbg!(safe_divide(10, 2));
    // dbg!(safe_divide(10, 0));

    todo!("Implement chain_divide using and_then");
    // dbg!(chain_divide(100, 5, 2));
    // dbg!(chain_divide(100, 0, 2));

    todo!("Implement get_voting_age using filter");
    // dbg!(get_voting_age(Some(25)));
    // dbg!(get_voting_age(Some(16)));
    // dbg!(get_voting_age(None));

    todo!("Implement get_config_or_default using or_else");
    // dbg!(get_config_or_default(Some("custom.toml".to_string())));
    // dbg!(get_config_or_default(None));

    todo!("Implement sum_nested_options");
    // let nested = vec![Some(Some(1)), None, Some(None), Some(Some(3))];
    // dbg!(sum_nested_options(nested));

    dbg!("Conclusion: Option combinators let you chain operations without explicit matching");
}
