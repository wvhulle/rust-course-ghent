//! Organizing multiple trait bounds with + and where clauses
//!
//! Learn when to use inline bounds vs where clauses for readability
#![allow(unused)]
use std::fmt::Debug;

// Simple types for demonstration - all traits derived
#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
struct Product {
    name: String,
    price: u32,
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
struct Measurement {
    value: f64,
    unit: String,
}

// Demonstration: Multiple type parameters - where clause improves readability
fn compare_and_clone<T, U>(first: &T, second: &U) -> (T, U)
where
    T: Clone + Debug,
    U: Clone + Debug,
{
    println!("First: {:?}", first);
    println!("Second: {:?}", second);
    (first.clone(), second.clone())
}

// Attempt 1: Inline bounds getting hard to read
// Uncomment to see how messy this gets:
//
// fn process_complex<T: Clone + Debug + PartialEq + PartialOrd>(a: &T, b: &T)
// -> bool {     println!("Comparing {:?} and {:?}", a, b);
//     a == b && a < b
// }

// Better: Same function with where clause
fn process_complex<T>(a: &T, b: &T) -> bool
where
    T: Clone + Debug + PartialEq + PartialOrd,
{
    println!("Comparing {:?} and {:?}", a, b);
    a == b || a < b
}

// Attempt 2: Multiple type parameters with inline bounds
// Uncomment to see the readability problem:
//
// fn transform<T: Clone + Debug, U: Clone + Debug, F: Fn(T) -> U>(item: T,
// func: F) -> U {     println!("Transforming {:?}", item);
//     func(item)
// }

// Better: where clause separates bounds from signature
fn transform<T, U, F>(item: T, func: F) -> U
where
    T: Clone + Debug,
    U: Debug,
    F: Fn(T) -> U,
{
    println!("Transforming {:?}", item);
    func(item)
}

/// Exercise: Write a function that finds the maximum of two values
fn find_max<T>(_a: &T, _b: &T) -> T {
    todo!("Add trait bounds for Clone and PartialOrd using +");
    todo!("Compare _a and _b, return clone of the larger one");
}

// Exercise: Convert this inline-bound function to use where clause
// Uncomment and refactor:
//
// fn sort_and_display<T: Ord + Debug + Clone>(mut items: Vec<T>) -> Vec<T> {
//     items.sort();
//     for item in &items {
//         println!("{:?}", item);
//     }
//     items
// }

fn sort_and_display<T>(_items: Vec<T>) -> Vec<T> {
    todo!("Add where clause with bounds: Ord + Debug + Clone");
    todo!("Make _items mutable and sort it");
    todo!("Print each item and return the sorted vector");
}

fn main() {
    let laptop = Product {
        name: "Laptop".to_string(),
        price: 999,
    };

    let mouse = Product {
        name: "Mouse".to_string(),
        price: 29,
    };

    dbg!(process_complex(&laptop, &mouse));

    let result = transform(laptop.clone(), |p: Product| {
        format!("{} costs ${}", p.name, p.price)
    });
    dbg!(result);

    todo!("Uncomment Attempt 1 - notice how hard it is to read");
    todo!("Uncomment Attempt 2 - compare with the where clause version");

    todo!("Implement find_max and test with laptop and mouse");

    todo!("Implement process_pair and call with laptop and measurement");

    todo!("Uncomment and refactor sort_and_display to use where clause");
    // let numbers = vec![5, 2, 8, 1, 9];
    // dbg!(sort_and_display(numbers));
}
