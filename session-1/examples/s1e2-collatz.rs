//   The Collatz Sequence is defined as follows, for an arbitrary n1 greater than zero:

//   - If n is even, the next number in the sequence is n / 2
//   - If n is odd, the next number in the sequence is 3n + 1
//   - The sequence ends when it reaches 1.

//   Determine the length of the collatz sequence beginning at `n`.
fn collatz_length(mut n: i32) -> u32 {
    todo!("Implement this")
}

fn main() {
    println!("Length: {}", collatz_length(11)); // should be 15
}
