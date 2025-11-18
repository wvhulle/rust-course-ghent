//! Where to put trait bounds: struct vs impl
//!
//! Discover why bounds belong on impl blocks, not struct definitions

use std::fmt::Debug;

// Demonstration: putting bounds on the struct definition
//
// Uncomment to see the problem:
//
// struct Container<T: Clone + Debug> {
//     value: T,
// }
//
// impl<T: Clone + Debug> Container<T> {
//     fn new(value: T) -> Self {
//         Container { value }
//     }
//
//     fn get_cloned(&self) -> T {
//         self.value.clone()
//     }
//
//     fn debug_print(&self) {
//         println!("{:?}", self.value);
//     }
// }

// Better: Bounds only on impl, not on struct
struct Container<T> {
    value: T,
}

impl<T> Container<T> {
    fn new(value: T) -> Self {
        Container { value }
    }
}

impl<T: Clone> Container<T> {
    fn get_cloned(&self) -> T {
        self.value.clone()
    }
}

impl<T: Debug> Container<T> {
    fn debug_print(&self) {
        println!("{:?}", self.value);
    }
}

// Exercise: Create a generic Cache struct
struct Cache<T> {
    // Add a field 'data' of type Option<T>
}

impl<T> Cache<T> {
    fn new() -> Self {
        todo!("Create Cache with data: None");
    }

    fn set(&mut self, _value: T) {
        todo!("Store _value in data as Some(_value)");
    }
}

// Exercise: Add impl block that only works when T: Clone
impl<T> Cache<T> {
    fn get_cloned(&self) -> Option<T> {
        todo!("Add trait bound T: Clone to this impl block");
        todo!("Clone the data if Some, return None if None");
    }
}

// Exercise: Add impl block that only works when T: Debug
impl<T> Cache<T> {
    fn print_contents(&self) {
        todo!("Add trait bound T: Debug to this impl block");
        todo!("Print the data using Debug");
    }
}

fn main() {
    let num_container = Container::new(42);
    dbg!(num_container.get_cloned());
    num_container.debug_print();

    todo!("Uncomment Attempt 1 - notice you write bounds twice");
    todo!("Try creating Container<NonCloneable> with bounded version");

    todo!("Implement Cache struct and all impl blocks");
    // let mut cache = Cache::new();
    // cache.set(100);
    // dbg!(cache.get_cloned());
    // cache.print_contents();
}
