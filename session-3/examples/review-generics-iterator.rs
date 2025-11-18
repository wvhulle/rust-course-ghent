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
        todo!("Return Some(current) and decrement, or None when current is 0")
    }
}

struct Fibonacci {
    current: u64,
    next: u64,
}

impl Fibonacci {
    fn new() -> Self {
        todo!("Initialize with current=0 and next=1")
    }
}

fn main() {
    let countdown = CountDown::new(5);

    for n in countdown {
        println!("{}", n);
    }

    let values: Vec<u32> = CountDown::new(3).collect();
    println!("{:?}", values);

    todo!("Implement Iterator for Fibonacci with Item = u64 and a working next() method");

    todo!("Create a Fibonacci and print first 10 numbers using .take(10)");
}
