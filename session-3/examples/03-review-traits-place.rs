//! Where to put trait bounds: struct vs impl

use std::fmt::Debug;

// Attempt 1: Putting bounds on the struct definition
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

struct Cache<T> {
    // TODO: Add a field 'data' of type Option<T>
}

impl<T> Cache<T> {
    fn new() -> Self {
        // TODO: Create Cache with data: None
        todo!("handle Option")
    }

    fn set(&mut self, _value: T) {
        // TODO: Store _value in data as Some(_value)
        todo!("handle Option")
    }
}

impl<T> Cache<T> {
    fn get_cloned(&self) -> Option<T> {
        // TODO: Add trait bound T: Clone to this impl block signature
        // TODO: Clone the data if Some, return None if None
        todo!("clone it")
    }
}

impl<T> Cache<T> {
    fn print_contents(&self) {
        // TODO: Add trait bound T: Debug to this impl block signature
        // TODO: Print the data using Debug
        todo!("add Debug")
    }
}

fn main() {
    let num_container = Container::new(42);
    dbg!(num_container.get_cloned());
    num_container.debug_print();

    // TODO: Uncomment Attempt 1 at the top
    // TODO: Notice you write bounds twice (struct and impl)

    // TODO: Implement Cache struct with data field
    // TODO: Implement all impl blocks with proper trait bounds
    // TODO: Uncomment and test:
    // let mut cache = Cache::new();
    // cache.set(100);
    // dbg!(cache.get_cloned());
    // cache.print_contents();
}
