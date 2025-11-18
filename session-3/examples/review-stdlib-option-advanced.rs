//! Learn chaining and more complex Option operations

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
        "Use or_else to return config if Some, or fetch from environment using std::env::var(\"CONFIG\").ok()"
    )
}

fn sum_nested_options(values: Vec<Option<Option<i32>>>) -> i32 {
    todo!("Use filter_map and flatten to extract all values and sum them")
}

fn main() {
    demonstrate_advanced();
    println!();

    dbg!(safe_divide(10, 2));
    dbg!(safe_divide(10, 0));

    dbg!(chain_divide(100, 5, 2));
    dbg!(chain_divide(100, 0, 2));

    dbg!(get_voting_age(Some(25)));
    dbg!(get_voting_age(Some(16)));
    dbg!(get_voting_age(None));

    dbg!(get_config_or_default(Some("custom.toml".to_string())));
    dbg!(get_config_or_default(None));

    let nested = vec![Some(Some(1)), None, Some(None), Some(Some(3))];
    dbg!(sum_nested_options(nested));
}
