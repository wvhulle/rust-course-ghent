//! Implementing standard library traits manually
//!
//! Learn the contract and responsibility of common traits

use std::fmt;

// Demonstration: A simple Display implementation
struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

// Your domain type for the exercises
#[derive(Debug, Clone, Copy)]
struct Temperature {
    celsius: f64,
}

impl Temperature {
    fn new(celsius: f64) -> Self {
        Temperature { celsius }
    }

    fn fahrenheit(&self) -> f64 {
        self.celsius * 9.0 / 5.0 + 32.0
    }
}

// Attempt 1: Try implementing Display without using write! macro
// Uncomment to see why this doesn't work:
//
// impl fmt::Display for Temperature {
//     fn fmt(&self, _f: &mut fmt::Formatter) -> fmt::Result {
//         println!("{}°C", self.celsius);
//         Ok(())
//     }
// }

// Exercise: Implement Display for Temperature
// impl fmt::Display for Temperature {
//     fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
//         // TODO: Use write! macro to format as '23.5°C'
//         // TODO: Handle the special case: 0.0 should display as '0°C' not '0.0°C'
//         todo!("use write!")
//     }
// }

// Exercise: Implement PartialEq for Temperature
// impl PartialEq for Temperature {
//     fn eq(&self, other: &Self) -> bool {
//         // TODO: Compare celsius values
//         // TODO: Think: should 20.0 == 20.00000001? Floating point equality is tricky!
//         todo!("compare f64")
//     }
// }

// Exercise: Implement PartialOrd for Temperature
// impl PartialOrd for Temperature {
//     fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
//         // TODO: Use self.celsius.partial_cmp(&other.celsius)
//         // TODO: Why partial_cmp and not cmp? Because f64 has NaN!
//         todo!("use partial_cmp")
//     }
// }

// Exercise: Implement From<f64> for Temperature
// impl From<f64> for Temperature {
//     fn from(celsius: f64) -> Self {
//         // TODO: Create Temperature from celsius value
//         todo!("create Temperature")
//     }
// }

fn demonstrate_display() {
    let p = Point { x: 10, y: 20 };
    println!("Point: {}", p);
    dbg!(format!("{}", p));
}

fn main() {
    println!("=== Display Trait ===");
    demonstrate_display();

    // TODO: Uncomment Attempt 1 - try Display with println!
    // TODO: Notice: Display must write to the Formatter, not stdout directly

    // TODO: Implement Display for Temperature
    // let temp = Temperature::new(23.5);
    // println!("Temperature: {}", temp);
    // dbg!(format!("{}", temp));

    println!("\n=== PartialEq Trait ===");
    // TODO: Implement PartialEq for Temperature
    // let temp1 = Temperature::new(20.0);
    // let temp2 = Temperature::new(20.0);
    // let temp3 = Temperature::new(25.0);
    // dbg!(temp1 == temp2);
    // dbg!(temp1 != temp3);

    println!("\n=== PartialOrd Trait ===");
    // TODO: Implement PartialOrd for Temperature
    // let cold = Temperature::new(10.0);
    // let warm = Temperature::new(25.0);
    // dbg!(cold < warm);
    // dbg!(warm > cold);
    // dbg!(cold <= Temperature::new(10.0));

    println!("\n=== From Trait ===");
    // TODO: Implement From<f64> for Temperature
    // let temp: Temperature = 20.0.into();
    // println!("Converted: {}", temp);

    println!("\n=== Combined: Using traits together ===");
    // TODO: After implementing all traits, uncomment this section
    // let mut temps = vec![
    //     Temperature::from(30.0),
    //     Temperature::from(15.0),
    //     Temperature::from(25.0),
    // ];
    //
    // // PartialOrd enables sorting
    // temps.sort_by(|a, b| a.partial_cmp(b).unwrap());
    // println!("Sorted temperatures:");
    // for temp in &temps {
    //     println!("  {}", temp);  // Display in action
    // }
    //
    // // PartialOrd enables max/min
    // let max = temps.iter().max();
    // println!("Hottest: {}", max.unwrap());

    // Key insights:
    // - Display is for user-facing output (different from Debug)
    // - PartialEq defines what equality means for your type
    // - PartialOrd enables <, >, <=, >= and sorting
    // - From enables ergonomic conversions with .into()
    // - These traits compose: implement a few, get many behaviors
}
