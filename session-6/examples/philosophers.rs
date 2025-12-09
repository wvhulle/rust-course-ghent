//! The Dining Philosophers problem demonstrates deadlock and how to avoid it.
//!
//! Five philosophers sit at a round table with chopsticks between them.
//! Each needs two chopsticks to eat. How do we prevent deadlock?

use std::{
    sync::{Arc, Mutex, mpsc::Sender},
    thread,
    time::Duration,
};

struct Chopstick;

struct Philosopher {
    name: String,
    left_chopstick: Arc<Mutex<Chopstick>>,
    right_chopstick: Arc<Mutex<Chopstick>>,
    thoughts: Sender<String>,
}

impl Philosopher {
    fn think(&self) {
        self.thoughts
            .send(format!("Eureka! {} has a new idea!", &self.name))
            .unwrap();
    }

    fn eat(&self) {
        // TODO: Lock left_chopstick, then right_chopstick
        // TODO: Print that philosopher is eating
        // TODO: Sleep for 10ms
        // Hint: let _left = self.left_chopstick.lock().unwrap();
        todo!("lock chopsticks")
    }
}

static PHILOSOPHERS: &[&str] = &["Socrates", "Hypatia", "Plato", "Aristotle", "Pythagoras"];

fn main() {
    // Create 5 chopsticks (one between each philosopher)
    let chopsticks: Vec<Arc<Mutex<Chopstick>>> =
        (0..5).map(|_| Arc::new(Mutex::new(Chopstick))).collect();

    let (tx, rx) = std::sync::mpsc::channel::<String>();

    // TODO: Create philosophers, each with left and right chopsticks
    // Philosopher i gets chopstick i (left) and chopstick (i+1) % 5 (right)
    let philosophers: Vec<Philosopher> = PHILOSOPHERS
        .iter()
        .enumerate()
        .map(|(i, name)| {
            // TODO: Create a Philosopher with correct chopsticks
            // Hint: Arc::clone(&chopsticks[i]) for left
            // Hint: Arc::clone(&chopsticks[(i + 1) % 5]) for right
            todo!("create philosopher")
        })
        .collect();

    // Spawn threads for each philosopher
    let handles: Vec<_> = philosophers
        .into_iter()
        .map(|p| {
            thread::spawn(move || {
                for _ in 0..100 {
                    p.think();
                    p.eat();
                }
            })
        })
        .collect();

    // Collect thoughts while philosophers work
    drop(tx);
    for thought in rx {
        println!("{thought}");
    }

    // Wait for all philosophers to finish
    for h in handles {
        h.join().unwrap();
    }
}

// Attempt 1: Run the code above - does it deadlock?
// If all philosophers pick up their left chopstick simultaneously,
// none can pick up their right (circular wait).

// Attempt 2: One fix - make the last philosopher pick up chopsticks in reverse order
// Uncomment and modify the philosopher creation:
//
// let (left, right) = if i == PHILOSOPHERS.len() - 1 {
//     // Last philosopher: right first to break the cycle
//     (Arc::clone(&chopsticks[(i + 1) % 5]), Arc::clone(&chopsticks[i]))
// } else {
//     (Arc::clone(&chopsticks[i]), Arc::clone(&chopsticks[(i + 1) % 5]))
// };
//
// This breaks the circular wait condition!
