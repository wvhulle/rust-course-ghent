//! Subtraits can add bounds on supertrait associated types

use std::fmt::Display;

trait Container {
    type Item;

    fn get(&self) -> &Self::Item;
}

// Attempt 1: Can you use methods from Item without bounds?
//
// trait Printable: Container {
//     fn print(&self) {
//         println!("{}", self.get());
//     }
// }

trait Printable: Container
where
    Self::Item: Display,
{
    fn print(&self) {
        println!("{}", self.get());
    }
}

struct Box<T> {
    value: T,
}

impl<T> Container for Box<T> {
    type Item = T;

    fn get(&self) -> &Self::Item {
        &self.value
    }
}

impl<T: Display> Printable for Box<T> {}

fn demonstrate_working() {
    let boxed = Box { value: 42 };
    boxed.print();

    let boxed_str = Box { value: "hello" };
    boxed_str.print();
}

// Attempt 2: What if Item doesn't implement Display?
//
// impl<T> Printable for Box<T> {}
//
// fn try_non_display() {
//     struct NotDisplay;
//     let boxed = Box { value: NotDisplay };
//     boxed.print();
// }

trait Storage {
    type Value;

    fn store(&mut self, value: Self::Value);
    fn retrieve(&self) -> &Self::Value;
}

trait CloneableStorage: Storage
where
    Self::Value: Clone,
{
    fn duplicate(&self) -> Self::Value {
        todo!("Step 1: Retrieve the value and clone it");
    }
}

struct Holder<T> {
    data: T,
}

impl<T> Storage for Holder<T> {
    type Value = T;

    fn store(&mut self, value: Self::Value) {
        self.data = value;
    }

    fn retrieve(&self) -> &Self::Value {
        &self.data
    }
}

impl<T: Clone> CloneableStorage for Holder<T> {}

// Attempt 3: Can we make non-Clone types cloneable?
//
// struct NotClone {
//     value: i32,
// }
//
// impl<T> CloneableStorage for Holder<T> {}

fn main() {
    demonstrate_working();

    todo!("Uncomment Attempt 1 - Can you call Display methods without bounds?");
    todo!("Uncomment Attempt 2 - What happens with non-Display types?");
    todo!("Uncomment Attempt 3 - Can you make non-Clone types cloneable?");

    let mut holder = Holder {
        data: "Rust".to_string(),
    };
    holder.store("Programming".to_string());
    dbg!(holder.duplicate());
}
