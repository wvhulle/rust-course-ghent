fn only_args(a: &i32, b: &i32) {
    todo!();
}

fn identity(a: &i32) -> &i32 {
    a
}

struct Foo(i32);
impl Foo {
    fn get(&self, other: &i32) -> &i32 {
        &self.0
    }
}

fn main() {}
