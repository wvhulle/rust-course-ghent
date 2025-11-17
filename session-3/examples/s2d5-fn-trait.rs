// The Fn Trait - Immutable Borrows
//
// The Fn trait represents closures that:
// - Can be called multiple times
// - Only borrow values from their environment immutably
// - Are the most flexible function trait (Fn is a supertrait of FnMut and FnOnce)
//
// Signature: Fn(&self) -> Output
//
// Key characteristics:
// - Can be called many times without consuming the closure
// - Cannot mutate captured variables
// - Can be shared across threads (if captured variables are Send + Sync)
//
// Your task: Work with closures that implement the Fn trait

#![allow(unused_variables)]
#![allow(dead_code)]

// Example: A function that takes a closure implementing Fn
// Note: We can call the closure multiple times
fn call_twice<F>(f: F) -> (String, String)
where
    F: Fn() -> String,
{
    let first = f();
    let second = f();
    (first, second)
}

// TODO: Write a function called `apply_to_each` that takes:
// - A slice of numbers (&[i32])
// - A closure that transforms each number (implements Fn(&i32) -> i32)
// Returns a Vec<i32> with the transformed values
//
// Signature: fn apply_to_each<F>(numbers: &[i32], f: F) -> Vec<i32>
//            where F: Fn(&i32) -> i32

// TODO: Write a function called `filter_strings` that takes:
// - A slice of strings (&[&str])
// - A predicate closure (implements Fn(&str) -> bool)
// Returns a Vec<String> containing only strings that match the predicate
//
// Hint: You'll call the closure once for each string

fn main() {
    println!("=== Example: Closures with Fn ===");
    
    // This closure captures 'prefix' immutably
    let prefix = "Hello";
    let greeter = || format!("{}, World!", prefix);
    
    let (first, second) = call_twice(greeter);
    println!("First call: {}", first);
    println!("Second call: {}", second);
    // Notice: we can still use 'prefix' here because it was only borrowed
    println!("Original prefix: {}", prefix);

    println!("\n=== Part 1: Capturing by immutable reference ===");
    
    let multiplier = 10;
    // TODO: Create a closure called 'scale' that captures 'multiplier' 
    // and takes one i32 parameter, returning the parameter multiplied by multiplier
    
    // TODO: Use call_twice with a closure that uses 'multiplier'
    // Verify that both calls produce the same result

    println!("\n=== Part 2: Using apply_to_each ===");
    
    let numbers = [1, 2, 3, 4, 5];
    
    // TODO: Use your apply_to_each function with a closure that doubles each number
    
    // TODO: Use your apply_to_each function with a closure that captures
    // a variable from the environment and adds it to each number

    println!("\n=== Part 3: Using filter_strings ===");
    
    let words = ["apple", "banana", "apricot", "cherry", "avocado"];
    
    // TODO: Use your filter_strings function to get all words starting with "a"
    
    // TODO: Create a closure that captures a minimum length and filters
    // words that are at least that long

    println!("\n=== Part 4: Understanding Fn ===");
    
    // This works: Fn closures can be called multiple times
    let add_one = |x: i32| x + 1;
    println!("First: {}", add_one(5));
    println!("Second: {}", add_one(10));
    
    // TODO: Try to create a closure that captures a mutable variable
    // and modifies it. What happens when you try to use it with call_twice?
    // Uncomment the following and observe the error:
    
    // let mut counter = 0;
    // let increment = || {
    //     counter += 1;
    //     counter
    // };
    // call_twice(increment); // This won't compile! Why?
    
    // Question: Why can't we use a mutating closure with functions expecting Fn?
    // Answer: Fn requires immutable borrows. Mutating closures need FnMut.
}
