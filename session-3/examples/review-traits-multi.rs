//! Multiple Trait Bounds Exercise
//!
//! Syntax options:
//! 1. fn func<T: Trait1 + Trait2>(param: &T)
//! 2. fn func<T>(param: &T) where T: Trait1 + Trait2
//!
//! Practice writing generic functions using standard library traits like
//! Display, Debug, Clone, PartialOrd, and Iterator.

use std::fmt::{Debug, Display};

#[derive(Debug, Clone, PartialEq, PartialOrd)]
struct Product {
    name: String,
    price: f64,
    stock: u32,
}

impl Display for Product {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} (${:.2})", self.name, self.price)
    }
}

#[derive(Debug, Clone, PartialEq, PartialOrd)]
struct Book {
    title: String,
    pages: u32,
    rating: f64,
}

impl Display for Book {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "\"{}\" - {} pages", self.title, self.pages)
    }
}

fn print_and_debug<T: Display + Debug>(item: &T) {
    println!("Display: {}", item);
    println!("Debug: {:?}", item);
}

fn find_max<T: PartialOrd + Clone>(a: &T, b: &T) -> T {
    if a > b { a.clone() } else { b.clone() }
}

fn print_collection<T, I>(items: I)
where
    I: IntoIterator<Item = T>,
    T: Display,
{
    for item in items {
        println!("- {}", item);
    }
}

fn clone_and_compare<T>(a: &T, b: &T) -> bool
where
    T: Clone + PartialEq,
{
    let cloned_a = a.clone();
    let cloned_b = b.clone();
    cloned_a == cloned_b
}

fn summarize<T: Display + Debug + Clone>(_item: &T) -> String {
    todo!()
}

fn cheaper_product(_a: &Product, _b: &Product) -> Product {
    todo!()
}

fn print_sorted<T>(_items: Vec<T>) {
    todo!()
}

fn main() {
    let laptop = Product {
        name: "Laptop".to_string(),
        price: 999.99,
        stock: 5,
    };

    let mouse = Product {
        name: "Mouse".to_string(),
        price: 29.99,
        stock: 50,
    };

    let rust_book = Book {
        title: "The Rust Programming Language".to_string(),
        pages: 560,
        rating: 4.8,
    };

    println!("=== Example: print_and_debug ===");
    print_and_debug(&laptop);
    print_and_debug(&rust_book);

    println!("\n=== Example: find_max ===");
    let max_product = find_max(&laptop, &mouse);
    println!("More expensive product: {}", max_product);

    println!("\n=== Example: print_collection ===");
    let products = vec![laptop.clone(), mouse.clone()];
    print_collection(&products);

    println!("\n=== Example: clone_and_compare ===");
    let laptop2 = laptop.clone();
    println!(
        "laptop == laptop2: {}",
        clone_and_compare(&laptop, &laptop2)
    );
    println!("laptop == mouse: {}", clone_and_compare(&laptop, &mouse));

    // Exercise: summarize
    // Create a summary string that includes both Display and Debug representations
    todo!();

    // Exercise: cheaper_product
    // Return a clone of the cheaper product using PartialOrd
    todo!();

    // Exercise: print_sorted
    // Sort and print a vector of items (needs: Ord + Display)
    // let numbers = vec![5, 2, 8, 1, 9];
    todo!();
}
