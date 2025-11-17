// Method name conflicts in Rust traits
//
// In C++, when multiple base classes have methods with the same name, you get
// ambiguity errors. The same happens in Rust when implementing multiple traits
// with overlapping method names.
//
// Your task: Fix the ambiguous method calls using fully qualified syntax,
// then implement a third conflicting trait.

#![allow(unused_variables)]
#![allow(dead_code)]

trait Drawable {
    fn render(&self) {
        println!("Rendering as graphic");
    }
}

trait Printable {
    fn render(&self) {
        println!("Rendering for printer");
    }
}

struct Document;
impl Drawable for Document {}
impl Printable for Document {}

// TODO: Define a new trait called `Displayable` with a `render` method
// that prints "Rendering to screen"

// TODO: Implement `Displayable` for `Document`

fn main() {
    let doc = Document;

    println!("=== Part 1: Fix the ambiguity ===");
    // TODO: Uncomment and fix these lines using fully qualified syntax
    // doc.render(); // ERROR: ambiguous!
    // Fix: Call Drawable::render
    // Fix: Call Printable::render

    println!("\n=== Part 2: Call all three render methods ===");
    // TODO: Call all three render methods (Drawable, Printable, Displayable)
    // using fully qualified syntax
}
