//! How can you store different types that implement the same trait in a Vec?

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

fn main() {
    let dog = Dog {
        name: "Rex".to_string(),
    };
    let cat = Cat {
        name: "Whiskers".to_string(),
    };

    todo!("Try to create a Vec containing both dog and cat. What error do you get?");

    todo!("Look at the error. Can you store &dyn Animal instead? Try: Vec<&dyn Animal>");

    todo!(
        "The references won't live long enough. Try using Box to own the values. What type should the Vec contain?"
    );

    todo!(
        "Loop through your vector and call .speak() on each animal. How do you access the method?"
    );

    todo!("Define a Cow struct that implements Animal, then add it to your vector");
}
