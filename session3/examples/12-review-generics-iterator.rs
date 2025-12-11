//! Associated Types with Iterator Trait

struct CountDown {
    current: u32,
}

impl CountDown {
    fn new(start: u32) -> Self {
        CountDown { current: start }
    }
}

impl Iterator for CountDown {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        // TODO: Return Some(current) and decrement, or None when current is 0
        todo!("handle Option")
    }
}

struct Fibonacci {
    current: u64,
    next: u64,
}

impl Fibonacci {
    fn new() -> Self {
        // TODO: Initialize with current=0 and next=1
        todo!("set fields")
    }
}

fn main() {
    let countdown = CountDown::new(5);

    for n in countdown {
        println!("{}", n);
    }

    let values: Vec<u32> = CountDown::new(3).collect();
    println!("{:?}", values);

    // TODO: Implement Iterator for Fibonacci
    // TODO: Set Item = u64 and implement next() to generate sequence
    // TODO: Use std::mem::replace to swap current and next

    // TODO: Create Fibonacci::new() and print first 10 numbers
    // TODO: Use .take(10) and a for loop or collect()
}
