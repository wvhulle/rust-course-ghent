//! Organizing multiple trait bounds with + and where clauses

use std::fmt::Debug;

#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
struct Product {
    name: String,
    price: u32,
}

fn demonstrate_where_clause<T, U>(first: &T, second: &U) -> (T, U)
where
    T: Clone + Debug,
    U: Clone + Debug,
{
    println!("First: {:?}", first);
    println!("Second: {:?}", second);
    (first.clone(), second.clone())
}

// Attempt 1: Inline bounds getting hard to read
// Uncomment to see the readability problem:
//
// fn process_complex<T: Clone + Debug + PartialEq + PartialOrd>(a: &T, b: &T) -> bool {
//     println!("Comparing {:?} and {:?}", a, b);
//     a <= b
// }

fn process_complex<T>(a: &T, b: &T) -> bool
where
    T: Clone + Debug + PartialEq + PartialOrd,
{
    println!("Comparing {:?} and {:?}", a, b);
    a <= b
}

// Attempt 2: Multiple type parameters with inline bounds
// Uncomment to see the difference:
//
// fn transform<T: Clone + Debug, U: Debug, F: Fn(T) -> U>(item: T, func: F) -> U {
//     println!("Transforming {:?}", item);
//     func(item)
// }

fn transform<T, U, F>(item: T, func: F) -> U
where
    T: Clone + Debug,
    U: Debug,
    F: Fn(T) -> U,
{
    println!("Transforming {:?}", item);
    func(item)
}

fn find_max<T>(_a: &T, _b: &T) -> T {
    // TODO: Add trait bounds using where: Clone + PartialOrd
    // TODO: Compare _a and _b, return clone of the larger one
    todo!()
}

// Attempt 3: Convert inline bounds to where clause
// Uncomment to see the original:
//
// fn sort_and_display<T: Ord + Debug + Clone>(mut items: Vec<T>) -> Vec<T> {
//     items.sort();
//     for item in &items {
//         println!("{:?}", item);
//     }
//     items
// }

fn sort_and_display<T>(_items: Vec<T>) -> Vec<T> {
    // TODO: Add where clause with: Ord + Debug + Clone
    // TODO: Make _items mutable, sort it, print each item, and return
    todo!()
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

    // TODO: Call demonstrate_where_clause(&laptop, &mouse)

    dbg!(process_complex(&laptop, &mouse));

    let result = transform(laptop.clone(), |p: Product| {
        format!("{} costs ${}", p.name, p.price)
    });
    dbg!(result);

    // TODO: Uncomment Attempt 1 and compare with process_complex
    // TODO: Uncomment Attempt 2 and compare with transform

    // TODO: Implement find_max and call with &laptop and &mouse
    // TODO: Use dbg! to print the result

    // TODO: Uncomment Attempt 3 (sort_and_display with inline bounds)
    // TODO: Refactor sort_and_display to use where clause instead
    // TODO: Test with: let products = vec![laptop.clone(), mouse.clone()];
}
