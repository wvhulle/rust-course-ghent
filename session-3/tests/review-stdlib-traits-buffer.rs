//! Implementing standard library traits for custom types
//!
//! You're building a temperature tracking system

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

// Demonstrate: A simple Display implementation
use std::fmt;

struct Point {
    x: i32,
    y: i32,
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

// Exercise: Implement Display for Temperature
// Show format like "23.5°C"
//
// impl fmt::Display for Temperature {
//     fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
//         todo!("Use write!(f, ...) to format as '{}°C'");
//     }
// }

// Exercise: Implement PartialEq for Temperature
//
// impl PartialEq for Temperature {
//     fn eq(&self, other: &Self) -> bool {
//         todo!("Compare celsius values");
//     }
// }

// Exercise: Implement PartialOrd for Temperature
//
// impl PartialOrd for Temperature {
//     fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
//         todo!("Use self.celsius.partial_cmp(&other.celsius)");
//     }
// }

// Exercise: Implement From<f64> for Temperature
//
// impl From<f64> for Temperature {
//     fn from(celsius: f64) -> Self {
//         todo!("Create Temperature from celsius value");
//     }
// }

// Attempt 1: Try implementing Display without using write! macro
// Uncomment to see why this doesn't work:
//
// impl fmt::Display for Temperature {
//     fn fmt(&self, _f: &mut fmt::Formatter) -> fmt::Result {
//         println!("{}°C", self.celsius);
//         Ok(())
//     }
// }

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn demo_point() {
        let p = Point { x: 10, y: 20 };
        assert_eq!(format!("{}", p), "(10, 20)");
    }

    #[test]
    fn display() {
        let temp = Temperature::new(23.5);
        assert_eq!(format!("{}", temp), "23.5°C");

        let freezing = Temperature::new(0.0);
        assert_eq!(format!("{}", freezing), "0°C");
    }

    #[test]
    fn equality() {
        let temp1 = Temperature::new(20.0);
        let temp2 = Temperature::new(20.0);
        let temp3 = Temperature::new(25.0);

        assert_eq!(temp1, temp2);
        assert_ne!(temp1, temp3);
    }

    #[test]
    fn ordering() {
        let cold = Temperature::new(10.0);
        let warm = Temperature::new(25.0);

        assert!(cold < warm);
        assert!(warm > cold);
        assert!(cold <= Temperature::new(10.0));
    }

    #[test]
    fn conversion() {
        let temp: Temperature = 20.0.into();
        assert_eq!(temp.celsius, 20.0);

        let freezing = Temperature::from(0.0);
        assert_eq!(freezing.fahrenheit(), 32.0);
    }

    #[test]
    fn combined_usage() {
        let temps = vec![
            Temperature::from(30.0),
            Temperature::from(15.0),
            Temperature::from(25.0),
        ];

        let max = temps.iter().max();
        assert_eq!(max, Some(&Temperature::new(30.0)));

        let formatted: Vec<String> = temps.iter().map(|t| format!("{}", t)).collect();

        assert_eq!(formatted, vec!["30°C", "15°C", "25°C"]);
    }
}
