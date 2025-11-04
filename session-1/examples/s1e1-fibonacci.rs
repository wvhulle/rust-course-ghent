// The Fibonacci sequence begins with [0, 1]. For n > 1, the next number is the sum of the previous two.

// Write a function fib(n) that calculates the nth Fibonacci number. When will this function panic?
fn fib(n: u32) -> u32 {
    if n < 2 {
        // The base case.
        return todo!("Implement this");
    } else {
        // The recursive case.
        return todo!("Implement this");
    }
}

fn main() {
    let n = 20;
    println!("fib({n}) = {}", fib(n));
}
