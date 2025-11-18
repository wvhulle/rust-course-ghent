//! Example from std: `Copy` requires `Clone`

use std::{error::Error, fmt::Debug};

trait Serializable {
    fn serialize(&self) -> String;
}

trait Persistable: Serializable + Debug {
    fn save(&self, path: &str) -> Result<(), Box<dyn Error>> {
        let data = self.serialize();
        println!("Saving to {}: {}", path, data);
        Ok(())
    }
}

#[derive(Debug)]
struct User {
    id: u64,
    name: String,
    email: String,
}

impl Serializable for User {
    fn serialize(&self) -> String {
        format!("{}|{}|{}", self.id, self.name, self.email)
    }
}

impl Persistable for User {}

#[derive(Debug)]
struct Config {
    host: String,
    port: u16,
}

impl Serializable for Config {
    fn serialize(&self) -> String {
        format!("{}:{}", self.host, self.port)
    }
}

impl Persistable for Config {}

fn persist_item<T: Persistable>(item: &T, path: &str) -> Result<(), Box<dyn Error>> {
    item.save(path)
}

// Task: Create a Product struct with name, price, and stock fields
// Make it Persistable by implementing Serializable and deriving Debug

fn main() {
    let user = User {
        id: 42,
        name: "Alice".to_string(),
        email: "alice@example.com".to_string(),
    };

    persist_item(&user, "/tmp/user.txt").unwrap();

    let config = Config {
        host: "localhost".to_string(),
        port: 8080,
    };

    persist_item(&config, "/tmp/config.txt").unwrap();

    // Create a Product and persist it
    todo!();
}
