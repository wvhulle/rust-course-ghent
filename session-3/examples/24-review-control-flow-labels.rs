//! Breaking out of nested loops without flag variables
//!
//! Discover how loop labels provide structured control flow

// The flag variable anti-pattern - messy but works
fn find_in_matrix_with_flag(matrix: &[[i32; 3]; 3], target: i32) -> Option<(usize, usize)> {
    let mut result = None;
    let mut found = false;

    for (i, row) in matrix.iter().enumerate() {
        for (j, &value) in row.iter().enumerate() {
            if value == target {
                result = Some((i, j));
                found = true;
                break;
            }
        }
        if found {
            break;
        }
    }
    result
}

// Attempt 1: Try breaking outer loop without label
// Uncomment to see the limitation:
//
// fn broken_nested_break(matrix: &[[i32; 3]; 3], target: i32) -> Option<(usize, usize)> {
//     let mut result = None;
//
//     for (i, row) in matrix.iter().enumerate() {
//         for (j, &value) in row.iter().enumerate() {
//             if value == target {
//                 result = Some((i, j));
//                 break;
//             }
//         }
//     }
//     result
// }

// Better: Labeled break eliminates the flag variable
fn find_in_matrix(matrix: &[[i32; 3]; 3], target: i32) -> Option<(usize, usize)> {
    let mut result = None;
    'outer: for (i, row) in matrix.iter().enumerate() {
        for (j, &value) in row.iter().enumerate() {
            if value == target {
                result = Some((i, j));
                break 'outer;
            }
        }
    }
    result
}

// Demonstrate: Continue to outer loop with labels
fn skip_negative_groups(groups: &[Vec<i32>]) -> i32 {
    let mut sum = 0;
    'groups: for group in groups {
        if group.is_empty() {
            continue 'groups;
        }
        for &value in group {
            if value < 0 {
                continue 'groups;
            }
            sum += value;
        }
    }
    sum
}

/// Exercise: Find first pair of numbers that sum to target
fn find_pair_sum(_numbers: &[i32], _target: i32) -> Option<(i32, i32)> {
    // TODO: Use nested loops with 'outer: label to search pairs
    todo!("use break");
    // TODO: Outer loop: enumerate through numbers
    todo!("use break");
    // TODO: Inner loop: iterate from index+1 to avoid duplicates
    todo!("convert type");
    // TODO: When sum equals target, break 'outer and return the pair
    todo!("use break");
}

fn main() {
    let matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];

    println!("=== The Flag Variable Anti-Pattern ===");
    dbg!(find_in_matrix_with_flag(&matrix, 5));
    println!("Notice: need 'found' flag and check it after inner loop\n");

    println!("=== Labeled Break Solution ===");
    dbg!(find_in_matrix(&matrix, 5));
    dbg!(find_in_matrix(&matrix, 10));
    println!("Cleaner: no flag variable needed!\n");

    println!("=== Labeled Continue ===");
    let groups = vec![vec![1, 2, 3], vec![], vec![4, -1, 5], vec![6, 7]];
    dbg!(skip_negative_groups(&groups));

    // TODO: Uncomment Attempt 1 - try to break outer loop without label
    todo!("use break");
    // TODO: Notice: break only exits the inner loop, outer loop continues!
    todo!("use break");

    println!("\n=== Exercise: Two Sum Problem ===");
    let numbers = vec![2, 7, 11, 15];
    // TODO: Implement find_pair_sum using labeled break
    todo!("use break");
    // dbg!(find_pair_sum(&numbers, 9));   // Should find (2, 7)
    // dbg!(find_pair_sum(&numbers, 18));  // Should find (7, 11)
    // dbg!(find_pair_sum(&numbers, 100)); // Should find None

    // Comparison with C's goto:
    // - Labels only work with loops (not arbitrary code blocks)
    // - Can only break/continue to outer scopes (not arbitrary jumps)
    // - More structured and safer than goto
    // - Compiler ensures you can't create spaghetti code
}
