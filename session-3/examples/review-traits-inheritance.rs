//! Traits vs Inheritance Exercise
//!
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

    todo!(
        "Refactor Warrior and Mage to use Stats struct instead of duplicating name and health fields"
    );
}
