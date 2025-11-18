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

struct Document;
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

    todo!("Call doc.render() using fully qualified syntax to call Drawable's version");

    todo!("Call doc.render() using fully qualified syntax to call Printable's version");

    todo!("Call doc.render() using fully qualified syntax to call Displayable's version");
}
