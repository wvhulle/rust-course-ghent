//! Rust doesn't have class inheritance like Python or Java.
//! This exercise shows the Rust way: composition and traits.

// In Python, you might use inheritance:
//
// class Character:
//     def __init__(self, name, health):
//         self.name = name
//         self.health = health
//
// class Warrior(Character):
//     def __init__(self, name, health, strength):
//         super().__init__(name, health)
//         self.strength = strength

// In Rust, we use composition instead

#[derive(Debug)]
struct Warrior {
    name: String,
    health: i32,
    strength: i32,
}

#[derive(Debug)]
struct Mage {
    name: String,
    health: i32,
    mana: i32,
}

trait Character {
    fn name(&self) -> &str;
    fn health(&self) -> i32;
    fn take_damage(&mut self, damage: i32);
}

impl Character for Warrior {
    fn name(&self) -> &str {
        &self.name
    }

    fn health(&self) -> i32 {
        self.health
    }

    fn take_damage(&mut self, damage: i32) {
        self.health -= damage;
    }
}

impl Character for Mage {
    fn name(&self) -> &str {
        &self.name
    }

    fn health(&self) -> i32 {
        self.health
    }

    fn take_damage(&mut self, damage: i32) {
        self.health -= damage;
    }
}

impl Warrior {
    fn attack(&self) -> i32 {
        todo!("Return damage based on strength")
    }
}

impl Mage {
    fn cast_spell(&mut self) -> i32 {
        todo!("Consume mana and return damage")
    }
}

struct Stats {
    name: String,
    health: i32,
}

fn print_status(_character: &dyn Character) {
    todo!("Print character name and health")
}

fn store_characters() {
    todo!("Create a Vec<Box<dyn Character>> and store warrior and mage");
    todo!("Loop through and call print_status on each");
}

// Try using dyn with Clone
// Uncomment to see why this fails:
//
// fn clone_character(_character: &dyn Character) -> Box<dyn Character> {
//     Box::new(_character.clone())
// }

// Try returning dyn without Box
// Uncomment to see the error:
//
// fn get_character() -> dyn Character {
//     Warrior {
//         name: "Test".to_string(),
//         health: 100,
//         strength: 10,
//     }
// }

// Attempt 3: Try using dyn in a struct field
// Uncomment to see the size issue:
//
// struct Party {
//     members: Vec<dyn Character>,
// }

// The limitations of dyn:
// 1. No Clone - trait objects can't be cloned automatically
// 2. No Sized - must use Box, &, or other pointer types
// 3. Runtime cost - dynamic dispatch is slower than static dispatch
// 4. Lost concrete type - can't access warrior.strength through &dyn Character

fn demonstrate_limitations() {
    let warrior = Warrior {
        name: "Conan".to_string(),
        health: 100,
        strength: 50,
    };

    let character: &dyn Character = &warrior;

    // This works - trait method
    dbg!(character.name());

    // Uncomment to see the error - lost access to concrete type methods:
    // dbg!(character.strength);
    // dbg!(character.attack());

    todo!("Notice: through &dyn Character, we can't access warrior-specific fields");
}

fn main() {
    let mut warrior = Warrior {
        name: "Conan".to_string(),
        health: 100,
        strength: 50,
    };

    let mut mage = Mage {
        name: "Gandalf".to_string(),
        health: 60,
        mana: 100,
    };

    println!("{} has {} health", warrior.name(), warrior.health());
    warrior.take_damage(20);
    println!(
        "{} takes damage! Health: {}",
        warrior.name(),
        warrior.health()
    );

    println!("{} has {} health", mage.name(), mage.health());
    mage.take_damage(15);
    println!("{} takes damage! Health: {}", mage.name(), mage.health());

    todo!("Call warrior.attack() and print the damage");

    todo!("Call mage.cast_spell() and print the damage");

    todo!("Use print_status() with both warrior and mage");

    todo!("Uncomment Attempt 1 - Character is not Clone");
    todo!("Uncomment Attempt 2 - dyn is not Sized");
    todo!("Uncomment Attempt 3 - Vec needs Sized types");

    todo!("Run demonstrate_limitations() to see lost type information");

    todo!("Implement store_characters() to see when Box<dyn Trait> is useful");

    todo!(
        "Refactor Warrior and Mage to use Stats struct instead of duplicating name and health \
         fields"
    );

    dbg!("Conclusion: dyn gives flexibility but loses type information and performance");
}
