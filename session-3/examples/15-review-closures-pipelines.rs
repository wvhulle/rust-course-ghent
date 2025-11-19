//! Functional programming style with method chaining pipelines
//!
//! You're processing user data for analytics and want to transform it using
//! pipelines

// Demonstrate: A typical imperative approach
fn imperative_process(numbers: &[i32]) -> i32 {
    let mut result = Vec::new();
    for n in numbers {
        if *n > 0 {
            result.push(n * 2);
        }
    }
    let mut sum = 0;
    for n in result {
        sum += n;
    }
    sum
}

// Demonstrate: The same logic in functional style
fn functional_process(numbers: &[i32]) -> i32 {
    numbers.iter().filter(|n| **n > 0).map(|n| n * 2).sum()
}

// Exercise: Process user ages
fn process_ages(ages: &[i32]) -> Vec<i32> {
    // TODO: Use .iter() to start the pipeline
    // TODO: Use .filter() to keep only ages >= 18
    // TODO: Use .map() to add 1 year to each age
    // TODO: Use .collect() to gather results into Vec<i32>
    todo!("use collect")
}

// Exercise: Find average of positive numbers
fn average_positive(numbers: &[i32]) -> Option<i32> {
    // TODO: Filter to keep only positive numbers
    // TODO: Collect into a Vec
    // TODO: Use .len() to get count (handle empty case with if-else)
    // TODO: Use .iter().sum() divided by count, wrapped in Some, or None if empty
    todo!("use iter")
}

// Exercise: Transform names pipeline
fn format_names(names: &[&str]) -> Vec<String> {
    // TODO: Start with .iter()
    // TODO: Use .map() to convert each name to uppercase with .to_uppercase()
    // TODO: Use .map() again to add 'Hello, ' prefix with format!()
    // TODO: Use .collect() to gather into Vec<String>
    todo!("use collect")
}

// Exercise: Complex data transformation
fn count_valid_emails(emails: &[&str]) -> usize {
    // TODO: Filter emails that contain '@'
    // TODO: Filter emails with length > 5
    // TODO: Use .count() to get the final count
    todo!("use count")
}

// Attempt 1: Mixing imperative and functional style
// Uncomment to see why this is awkward:
//
// fn mixed_style(numbers: &[i32]) -> i32 {
//     let mut sum = 0;
//     numbers
//         .iter()
//         .filter(|n| **n > 0)
//         .for_each(|n| sum += n);  // Captures sum mutably
//     sum
// }

// Attempt 2: Breaking the chain unnecessarily
// Uncomment to see the verbose version:
//
// fn broken_chain(numbers: &[i32]) -> Vec<i32> {
//     let iter = numbers.iter();
//     let filtered = iter.filter(|n| **n > 0);
//     let mapped = filtered.map(|n| n * 2);
//     let result = mapped.collect();
//     result
// }

fn main() {
    let demo_numbers = vec![1, -2, 3, -4, 5];

    dbg!(imperative_process(&demo_numbers));
    dbg!(functional_process(&demo_numbers));

    // TODO: Uncomment Attempt 1 to see the mixed style issue
    // TODO: Uncomment Attempt 2 to see how verbose broken chains are

    // Test process_ages
    let ages = vec![15, 18, 25, 17, 30];
    dbg!(process_ages(&ages));

    // Test average_positive
    let numbers = vec![-5, 10, -3, 20, 30];
    dbg!(average_positive(&numbers));
    dbg!(average_positive(&[]));

    // Test format_names
    let names = vec!["alice", "bob", "charlie"];
    dbg!(format_names(&names));

    // Test count_valid_emails
    let emails = vec!["a@b.com", "invalid", "test@example.com", "x@y", "nope"];
    dbg!(count_valid_emails(&emails));
}
