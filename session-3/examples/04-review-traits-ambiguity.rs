//! Fix ambiguous method calls using fully qualified syntax

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

// We create a unit struct: a struct with no fields (or runtime overhead)
struct Document;

// Assume the following impl blocks are useful
impl Drawable for Document {}
impl Printable for Document {}

trait Displayable {
    fn render(&self) {
        todo!("Print 'Rendering to screen'")
    }
}

impl Displayable for Document {}

fn main() {
    let doc = Document;

    todo!("Try to print all messages (use the trait names like this: `Trait::render`).");

    // doc.render();
}
