// Scenario 1: Diamond pattern with supertraits
// This works fine because there's only ONE implementation of A
trait Animal {
    fn speak(&self) {
        println!("Some sound");
    }
}

trait Mammal: Animal {}
trait Pet: Animal {}

struct Dog;

impl Animal for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}
impl Mammal for Dog {}
impl Pet for Dog {}

// Scenario 2: Two traits with same method name (ambiguity)
trait Drawable {
    fn draw(&self) {
        println!("Drawing a shape");
    }
}

trait Printable {
    fn draw(&self) {
        println!("Drawing on paper");
    }
}

struct Canvas;
impl Drawable for Canvas {}
impl Printable for Canvas {}

fn main() {
    println!("=== Scenario 1: Supertrait Diamond (No Problem) ===");
    let dog = Dog;
    dog.speak(); // No ambiguity - only one implementation exists

    println!("\n=== Scenario 2: Method Name Conflict (Ambiguity) ===");
    let canvas = Canvas;
    // canvas.draw(); // ERROR: ambiguous! Which draw() to call?

    // Solution: Use fully qualified syntax
    <Canvas as Drawable>::draw(&canvas);
    <Canvas as Printable>::draw(&canvas);
}
