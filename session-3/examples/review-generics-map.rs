//! Make Counter generic over the type of value being tracked

use std::collections::HashMap;

struct Counter<T> {
    values: HashMap<T, u64>,
}

impl<T> Counter<T> {
    fn new() -> Self {
        todo!("Create a new Counter with an empty HashMap")
    }

    fn count(&mut self, _value: T) {
        todo!("Increment the count for the given value. If the value hasn't been seen, insert it with count 1")
    }

    fn times_seen(&self, _value: T) -> u64 {
        todo!("Return the number of times the given value has been seen, or 0 if never seen")
    }
}

fn main() {
    let mut ctr = Counter::new();
    ctr.count(13);
    ctr.count(14);
    ctr.count(16);
    ctr.count(14);
    ctr.count(14);
    ctr.count(11);

    for i in 10..20 {
        println!("saw {} values equal to {}", ctr.times_seen(i), i);
    }

    let mut strctr = Counter::new();
    strctr.count("apple");
    strctr.count("orange");
    strctr.count("apple");
    println!("got {} apples", strctr.times_seen("apple"));
}
