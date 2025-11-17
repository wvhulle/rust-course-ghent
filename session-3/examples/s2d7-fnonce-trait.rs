// The FnOnce Trait - Consuming Closures
//
// The FnOnce trait represents closures that:
// - Can only be called ONCE
// - May consume (take ownership of) values from their environment
// - Are the least restrictive function trait (all closures implement FnOnce)
//
// Signature: FnOnce(self) -> Output
//
// Key characteristics:
// - Consumes itself when called (takes ownership)
// - Useful when you need to move values out of the closure's environment
// - Common use cases: spawning threads, lazy initialization
// - All closures implement FnOnce (it's the base trait)
//
// Trait hierarchy: Fn: FnMut: FnOnce
// (Every Fn is a FnMut, and every FnMut is a FnOnce)
//
// Your task: Work with closures that implement only FnOnce

#![allow(unused_variables)]
#![allow(dead_code)]

// Example: A function that accepts a FnOnce closure
// Note: We can only call f() once because it might consume itself
fn call_once<F, T>(f: F) -> T
where
    F: FnOnce() -> T,
{
    f() // Can only call this once!
}

// TODO: Write a function called `lazy_init` that takes:
// - A closure that produces a value of type T (implements FnOnce() -> T)
// Returns the value produced by calling the closure once
//
// This pattern is useful for expensive initializations that should only happen once
//
// Signature: fn lazy_init<F, T>(initializer: F) -> T
//            where F: FnOnce() -> T

// TODO: Write a function called `transform_and_consume` that takes:
// - A value of type T
// - A closure that consumes T and produces U (implements FnOnce(T) -> U)
// Returns the transformed value
//
// Signature: fn transform_and_consume<T, U, F>(value: T, f: F) -> U
//            where F: FnOnce(T) -> U

fn main() {
    println!("=== Example: Closures with FnOnce ===");
    
    // This closure moves 'data' into itself and consumes it
    let data = String::from("Hello, Rust!");
    let consumer = || {
        // Move 'data' into the returned value
        data // This moves ownership out
    };
    
    // We can only call this once
    let result = call_once(consumer);
    println!("Result: {}", result);
    // consumer(); // ERROR: consumer was consumed!
    // println!("{}", data); // ERROR: data was moved!

    println!("\n=== Part 1: Understanding move semantics ===");
    
    let message = String::from("Important data");
    
    // TODO: Create a closure that moves 'message' and returns it in uppercase
    // let uppercase_consumer = || { ... };
    
    // TODO: Call your closure with call_once and print the result
    
    // Question: Can you call the closure again? Can you use 'message'?
    // Try uncommenting these lines:
    // uppercase_consumer(); // What happens?
    // println!("{}", message); // What happens?

    println!("\n=== Part 2: Closures that move parts of their environment ===");
    
    let numbers = [1, 2, 3, 4, 5];
    
    // TODO: Create a closure that moves 'numbers' into a thread
    // (Just simulate this by moving into a closure that returns the sum)
    // let sum_consumer = || { ... };
    
    // TODO: Use call_once to get the sum
    
    println!("\n=== Part 3: lazy_init pattern ===");
    
    // TODO: Use your lazy_init function to create an expensive Vec
    // that is only allocated when first needed
    // let expensive_vec = lazy_init(|| {
    //     println!("Allocating expensive vector...");
    //     vec![1, 2, 3, 4, 5]
    // });
    
    println!("\n=== Part 4: transform_and_consume ===");
    
    let names = ["Alice", "Bob", "Charlie"];
    
    // TODO: Use transform_and_consume to convert the Vec into a single String
    // let greeting = transform_and_consume(names, |n| {
    //     format!("Hello: {}", n.join(", "))
    // });
    // println!("{}", greeting);

    println!("\n=== Part 5: Understanding the trait hierarchy ===");
    
    // Example 1: Fn closure can be used as FnOnce
    let x = 10;
    let fn_closure = || x * 2;  // Implements Fn
    let result = call_once(fn_closure);  // Works! Fn: FnOnce
    println!("Fn as FnOnce: {}", result);
    
    // Example 2: FnMut closure can be used as FnOnce
    let mut count = 0;
    let fnmut_closure = || {
        count += 1;
        count
    };  // Implements FnMut
    let result = call_once(fnmut_closure);  // Works! FnMut: FnOnce
    println!("FnMut as FnOnce: {}", result);
    
    // Example 3: True FnOnce closure (moves ownership)
    let data = vec![1, 2, 3];
    let fnonce_closure = || {
        drop(data);  // Consumes data
        "Data consumed"
    };  // Only implements FnOnce
    let result = call_once(fnonce_closure);  // Must be FnOnce
    println!("FnOnce only: {}", result);

    println!("\n=== Key Takeaways ===");
    println!("- FnOnce can only be called once");
    println!("- All closures implement FnOnce (it's the base trait)");
    println!("- Closures that move values can only be FnOnce");
    println!("- Trait hierarchy: Fn ⊂ FnMut ⊂ FnOnce");
    println!("- Use FnOnce when you need to transfer ownership");
    
    println!("\n=== Real-world use case: Thread spawning ===");
    // Threads need FnOnce because they run in a different context
    // and need to own their data
    
    let data = [1, 2, 3, 4, 5];
    let handle = std::thread::spawn(move || {
        // 'move' forces the closure to take ownership
        data.iter().sum::<i32>()
    });
    
    let sum = handle.join().unwrap();
    println!("Sum from thread: {}", sum);
    // println!("{:?}", data); // ERROR: data was moved into the thread!
}
