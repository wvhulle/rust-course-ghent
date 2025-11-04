// Arrays can contain other arrays:
// ```rs
// let array = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
// ```
// Use an array such as the above to write a function transpose that transposes a matrix (turns rows into columns)
fn transpose(matrix: [[i32; 3]; 3]) -> [[i32; 3]; 3] {
    todo!()
}

fn main() {
    let matrix = [
        [101, 102, 103], // <-- the comment makes rustfmt add a newline
        [201, 202, 203],
        [301, 302, 303],
    ];

    println!("Original:");
    for row in &matrix {
        println!("{:?}", row);
    }

    let transposed = transpose(matrix);

    println!("\nTransposed:");
    for row in &transposed {
        println!("{:?}", row);
    }
}

// How would you do it with destructuring?
