//! In this exercise, you need to implement an iterator adapter: `MyFilter`.
//! The `MyMap` adapter is already implemented as a demonstration and takes an iterator and a closure. It applies the closure to each item of the iterator, yielding the results.
//!
//! # Your task: implement `MyFilter`
//!
//! The `MyFilter` adapter should take an iterator and a closure, and yield only those items for which the closure returns `true`.
//! You will need to define the struct for the adapter and implement the `Iterator` trait.
//! You can test your adapter in the `main` function provided below.
struct MyMap<I, F> {
    iter: I,
    f: F,
}
impl<I, F, B> Iterator for MyMap<I, F>
where
    I: Iterator,
    F: FnMut(I::Item) -> B,
{
    type Item = B;

    fn next(&mut self) -> Option<Self::Item> {
        self.iter.next().map(&mut self.f)
    }
}
fn main() {
    let nums = vec![1, 2, 3, 4];
    let mut my_map = MyMap {
        iter: nums.into_iter(),
        f: |x| x * 2,
    };

    while let Some(val) = my_map.next() {
        println!("{}", val);
    }
}

// Bonus: can you make `MyMap` and `MyFilter` chainable, so that you can do something like this?
// ```
// let nums = vec![1, 2, 3, 4];
// let mut my_map = MyMap {
//     iter: nums.into_iter(),
//     f: |x| x * 2,
// }.my_filter(|x| x > 4);
// ```
