// The FnMut Trait - Mutable Borrows
//
// The FnMut trait represents closures that:
// - Can be called multiple times
// - May mutate values from their environment
// - Are more restrictive than Fn (but more flexible than FnOnce)
//
// Signature: FnMut(&mut self) -> Output
//
// Key characteristics:
// - Can be called many times without consuming the closure
// - Can mutate captured variables
// - Requires mutable access, so cannot be shared across threads easily
// - Common use case: accumulating results across multiple calls
//
// Your task: Work with closures that implement the FnMut trait

#![allow(unused_variables)]
#![allow(dead_code)]

// Example: A function that accepts a FnMut closure
// Note: We need 'mut' because FnMut requires mutable access
fn apply_n_times<F>(mut f: F, n: usize) -> Vec<String>
where
    F: FnMut() -> String,
{
    let mut results = Vec::new();
    for _ in 0..n {
        results.push(f());
    }
    results
}

// TODO: Write a function called `accumulate` that takes:
// - An initial value of type T
// - A slice of items of type U
// - A closure that takes (&mut T, &U) and updates the accumulator
// Returns the final accumulated value
//
// Signature: fn accumulate<T, U, F>(initial: T, items: &[U], mut f: F) -> T
//            where F: FnMut(&mut T, &U)

// TODO: Write a function called `generate_sequence` that takes:
// - A starting number (i32)
// - A count (usize) 
// - A closure that takes the current number and returns the next one
// Returns a Vec<i32> with the sequence
//
// Hint: The closure needs to remember the current state between calls

fn main() {
    println!("=== Example: Closures with FnMut ===");
    
    // This closure captures 'counter' mutably
    let mut counter = 0;
    let mut increment = || {
        counter += 1;
        format!("Count: {}", counter)
    };
    
    let results = apply_n_times(increment, 5);
    for result in &results {
        println!("{}", result);
    }
    println!("Final counter value: {}", counter); // 5

    println!("\n=== Part 1: Building a stateful closure ===");
    
    // TODO: Create a closure that maintains a running sum
    // It should take a number and add it to the sum, returning the new total
    let mut sum = 0;
    // let mut add_to_sum = |x: i32| { ... };
    
    // TODO: Call your closure multiple times and print the results
    // println!("After adding 5: {}", add_to_sum(5));   // Should print 5
    // println!("After adding 3: {}", add_to_sum(3));   // Should print 8
    // println!("After adding 10: {}", add_to_sum(10)); // Should print 18

    println!("\n=== Part 2: Using accumulate ===");
    
    let numbers = [1, 2, 3, 4, 5];
    
    // TODO: Use your accumulate function to sum all numbers
    // let total = accumulate(0, &numbers, |acc, &n| *acc += n);
    // println!("Sum: {}", total);
    
    // TODO: Use your accumulate function to build a string from words
    let words = ["Hello", "world", "from", "Rust"];
    // let sentence = accumulate(String::new(), &words, |acc, &word| {
    //     if !acc.is_empty() {
    //         acc.push(' ');
    //     }
    //     acc.push_str(word);
    // });
    // println!("Sentence: {}", sentence);

    println!("\n=== Part 3: Stateful transformations ===");
    
    // TODO: Create a closure that generates sequential IDs
    // Each call should return the next ID in sequence
    let mut next_id = 0;
    // let mut id_generator = || { ... };
    
    // println!("ID 1: {}", id_generator());
    // println!("ID 2: {}", id_generator());
    // println!("ID 3: {}", id_generator());

    println!("\n=== Part 4: Understanding FnMut vs Fn ===");
    
    // This works: FnMut can modify captured variables
    let mut value = 10;
    let mut doubler = || {
        value *= 2;
        value
    };
    println!("First call: {}", doubler());  // 20
    println!("Second call: {}", doubler()); // 40
    
    // Question: Can we pass 'doubler' to a function expecting Fn?
    // Try uncommenting this:
    // fn needs_fn<F: Fn() -> i32>(f: F) -> i32 { f() }
    // needs_fn(doubler); // Won't compile! FnMut is not Fn
    
    // However, an Fn closure CAN be used where FnMut is expected!
    let x = 5;
    let reader = || format!("Value: {}", x * 2);  // This is Fn (only reads)
    let results = apply_n_times(reader, 3);  // Works! Fn implements FnMut
    println!("Results: {:?}", results);
    
    println!("\n=== Key Takeaway ===");
    println!("- Fn closures can be used where FnMut is expected");
    println!("- FnMut closures CANNOT be used where Fn is expected");
    println!("- Fn is a subtrait of FnMut: Fn: FnMut");
}
