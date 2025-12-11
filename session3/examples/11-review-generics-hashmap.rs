//! Make Counter generic over the type of value being tracked

use std::collections::HashMap;

struct Counter<T> {
    values: HashMap<T, u64>,
}

impl<T> Counter<T> {
    fn new() -> Self {
        // TODO: Create a new Counter with an empty HashMap
        todo!("use map")
    }

    fn count(&mut self, _value: T) {
        // TODO: Add trait bounds Eq + Hash to the impl block
        // TODO: Increment count for _value (insert 1 if not seen before)
        // TODO: Use entry() API or get + insert
        todo!("inc count")
    }

    fn times_seen(&self, _value: T) -> u64 {
        // TODO: Add trait bounds Eq + Hash to the impl block
        // TODO: Return count for _value, or 0 if never seen
        // TODO: Use get() and unwrap_or
        todo!("use unwrap_or")
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
