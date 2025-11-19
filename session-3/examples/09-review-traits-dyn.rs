//! How can you store different types that implement the same trait in a Vec?

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
    fn is_alive(&self) -> bool {
        self.health() > 0
    }
}

impl Character for Warrior {
    fn name(&self) -> &str {
        &self.name
    }

    fn health(&self) -> i32 {
        self.health
    }
}

impl Character for Mage {
    fn name(&self) -> &str {
        &self.name
    }

    fn health(&self) -> i32 {
        self.health
    }
}

impl Warrior {
    fn attack(&self) -> i32 {
        self.strength * 2
    }
}

impl Mage {
    fn cast_spell(&mut self) -> i32 {
        if self.mana >= 10 {
            self.mana -= 10;
            30
        } else {
            0
        }
    }
}

fn print_status(character: &dyn Character) {
    let status = if character.is_alive() {
        "alive"
    } else {
        "dead"
    };
    println!(
        "{} has {} HP and is {}",
        character.name(),
        character.health(),
        status
    );
}

// Attempt 1: Try storing different types in a Vec
// Uncomment to see what happens:
//
// fn create_party_attempt1() {
//     let warrior = Warrior {
//         name: "Conan".to_string(),
//         health: 100,
//         strength: 50,
//     };
//
//     let mage = Mage {
//         name: "Gandalf".to_string(),
//         health: 60,
//         mana: 100,
//     };
//
//     let party = vec![warrior, mage];
//     dbg!(party.len());
// }

// Attempt 2: Try returning dyn without Box
// Uncomment to discover the Sized requirement:
//
// fn get_character() -> dyn Character {
//     Warrior {
//         name: "Test".to_string(),
//         health: 100,
//         strength: 10,
//     }
// }

// Attempt 3: Try using dyn directly in a Vec
// Uncomment to see the size issue:
//
// fn create_party_attempt3() {
//     let party: Vec<dyn Character> = Vec::new();
//     dbg!(party.len());
// }

fn create_party() -> Vec<Box<dyn Character>> {
    // TODO: Create a Vec<Box<dyn Character>> with a warrior and mage
    todo!()
}

fn main() {
    let warrior = Warrior {
        name: "Conan".to_string(),
        health: 100,
        strength: 50,
    };

    let mage = Mage {
        name: "Gandalf".to_string(),
        health: 60,
        mana: 100,
    };

    // TODO: Call print_status with &warrior and &mage

    // TODO: Uncomment Attempt 1. Read the error about mismatched types
    // TODO: Uncomment Attempt 2. See why dyn is not Sized
    // TODO: Uncomment Attempt 3. See why Vec needs Sized types

    // TODO: Implement create_party() using Box<dyn Character>
    // TODO: Loop through the party and call print_status on each member

    let warrior2 = Warrior {
        name: "Beowulf".to_string(),
        health: 120,
        strength: 60,
    };

    let character_ref: &dyn Character = &warrior2;

    dbg!(character_ref.name());

    // TODO: Try to access character_ref.strength
    // TODO: Try to call character_ref.attack()

    // Pattern: dyn gives flexibility but loses concrete type information
}
