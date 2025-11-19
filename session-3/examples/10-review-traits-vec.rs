//! When dyn trait objects are actually useful
//!
//! Storing heterogeneous types that share a trait in collections

trait Animal {
    fn speak(&self) -> String;
}

struct Dog {
    name: String,
}

impl Animal for Dog {
    fn speak(&self) -> String {
        format!("{} says: Woof!", self.name)
    }
}

struct Cat {
    name: String,
}

impl Animal for Cat {
    fn speak(&self) -> String {
        format!("{} says: Meow!", self.name)
    }
}

struct Cow {
    name: String,
}

impl Animal for Cow {
    fn speak(&self) -> String {
        format!("{} says: Moo!", self.name)
    }
}

// Attempt 1: Try storing concrete types directly
// Uncomment to see the error:
//
// fn try_mixed_vec() {
//     let dog = Dog { name: "Rex".to_string() };
//     let cat = Cat { name: "Whiskers".to_string() };
//
//     let animals = vec![dog, cat];
//
//     for animal in animals {
//         println!("{}", animal.speak());
//     }
// }

// Attempt 2: Try with references
// Uncomment to see the lifetime issue:
//
// fn try_references() -> Vec<&dyn Animal> {
//     let dog = Dog { name: "Rex".to_string() };
//     let cat = Cat { name: "Whiskers".to_string() };
//
//     vec![&dog, &cat]
// }

// Solution: Box<dyn Trait> for owned heterogeneous collections
fn demonstrate_boxed_animals() {
    let animals: Vec<Box<dyn Animal>> = vec![
        Box::new(Dog {
            name: "Rex".to_string(),
        }),
        Box::new(Cat {
            name: "Whiskers".to_string(),
        }),
        Box::new(Cow {
            name: "Bessie".to_string(),
        }),
    ];

    println!("=== All animals speak ===");
    for animal in &animals {
        println!("{}", animal.speak());
    }
}

// Real-world use case: Loading animals from runtime data
fn load_animals_from_config(animal_type: &str, name: &str) -> Box<dyn Animal> {
    match animal_type {
        "dog" => Box::new(Dog {
            name: name.to_string(),
        }),
        "cat" => Box::new(Cat {
            name: name.to_string(),
        }),
        "cow" => Box::new(Cow {
            name: name.to_string(),
        }),
        _ => panic!("Unknown animal type"),
    }
}

// Exercise: Build a zoo from runtime data
fn build_zoo() -> Vec<Box<dyn Animal>> {
    // TODO: Step 1: Create an empty Vec<Box<dyn Animal>>
    todo!("create vec");
    // TODO: Step 2: Use load_animals_from_config to add: dog 'Max', cat 'Luna', cow 'Daisy'
    todo!("convert type");
    // TODO: Step 3: Return the vector
    todo!("create vec");
}

// Exercise: Process all animals
fn make_all_speak(_animals: &[Box<dyn Animal>]) {
    // TODO: Loop through animals and print each one's speak() result
    todo!("handle Result");
}

// Exercise: Add new animal type
// struct Bird {
//     // TODO: Add name field
//     todo!("create vec");
// }

// impl Animal for Bird {
//     fn speak(&self) -> String {
//         // TODO: Return '<name> says: Tweet!'
//         todo!("return value");
//     }
// }

fn main() {
    println!("=== Demonstration ===");
    demonstrate_boxed_animals();

    println!("\n=== Runtime type selection ===");
    let runtime_animals = vec![
        load_animals_from_config("dog", "Buddy"),
        load_animals_from_config("cat", "Mittens"),
        load_animals_from_config("cow", "Clarabelle"),
    ];

    for animal in &runtime_animals {
        println!("{}", animal.speak());
    }

    // TODO: Uncomment Attempt 1 - Vec can only hold one concrete type
    todo!("call fn");
    // TODO: Uncomment Attempt 2 - Local variables don't live long enough
    todo!("loop speak");

    println!("\n=== Exercise: Build zoo ===");
    // TODO: Implement build_zoo() function
    todo!("implement");
    // let zoo = build_zoo();
    // make_all_speak(&zoo);

    // TODO: Uncomment Bird struct and impl, then add birds to the zoo
    todo!("uncomment");
    // let bird = Box::new(Bird { name: "Tweety".to_string() });

    dbg!(
        "Conclusion: Box<dyn Trait> solves heterogeneous collections when types aren't known at compile time"
    );
}
