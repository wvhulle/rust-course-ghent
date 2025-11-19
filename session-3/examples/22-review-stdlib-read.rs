//! Implementing the Read trait for a custom decoder
//!
//! Build a ROT13 cipher that implements std::io::Read

use std::io::{self, Read};

// Demonstration: Simple passthrough reader
struct Uppercase<R: Read> {
    input: R,
}

impl<R: Read> Read for Uppercase<R> {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        let bytes_read = self.input.read(buf)?;

        for byte in &mut buf[..bytes_read] {
            if byte.is_ascii_lowercase() {
                *byte = byte.to_ascii_uppercase();
            }
        }

        Ok(bytes_read)
    }
}

fn demonstrate_uppercase() {
    let mut upper = Uppercase {
        input: "hello world".as_bytes(),
    };

    let mut result = String::new();
    upper.read_to_string(&mut result).unwrap();

    println!("Original: hello world");
    println!("Uppercase: {}", result);
}

// Exercise: Implement Read for RotDecoder
struct RotDecoder<R: Read> {
    input: R,
    rot: u8,
}

// Helper function for ROT13
fn rotate_byte(byte: u8, rot: u8) -> u8 {
    // TODO: Check if byte.is_ascii_alphabetic()
    todo!("check alpha");
    // TODO: Find the base: 'a' for lowercase, 'A' for uppercase
    todo!("iterate buf");
    // TODO: Calculate: ((byte - base + rot) % 26) + base
    todo!("rotate fn");
    // TODO: Return rotated byte, or original if not alphabetic
    todo!("use if");
}

// impl<R: Read> Read for RotDecoder<R> {
//     fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
//         // TODO: Call self.input.read(buf)? to get bytes_read
// todo!("call read")
//         // TODO: Iterate through buf[..bytes_read]
// todo!("rotate byte");
//         // TODO: Apply rotate_byte to each byte
// todo!("impl Read");
//         // TODO: Return Ok(bytes_read)
// todo!("handle Result");
//     }
// }

fn main() {
    println!("=== Demonstration: Uppercase Reader ===");
    demonstrate_uppercase();

    println!("\n=== Exercise: ROT13 Decoder ===");
    // TODO: Implement rotate_byte helper function
    todo!("implement");
    // TODO: Implement Read trait for RotDecoder
    todo!("implement");

    // Test with ROT13 joke
    // let mut rot = RotDecoder {
    //     input: "Gb trg gb gur bgure fvqr!".as_bytes(),
    //     rot: 13,
    // };
    // let mut result = String::new();
    // rot.read_to_string(&mut result).unwrap();
    // println!("Encoded: Gb trg gb gur bgure fvqr!");
    // println!("Decoded: {}", result);

    println!("\n=== Challenge: Chaining ===");
    // TODO: What happens if you chain two RotDecoders together?
    todo!("return byte");
    // let encoded = "Uryyb, Jbeyq!";
    // let first = RotDecoder {
    //     input: encoded.as_bytes(),
    //     rot: 13,
    // };
    // let mut second = RotDecoder {
    //     input: first,
    //     rot: 13,
    // };
    // let mut final_result = String::new();
    // second.read_to_string(&mut final_result).unwrap();
    // println!("Double ROT13: {}", final_result);

    // Key insights:
    // - Read trait enables composition: your decoder works with any Read source
    // - You can chain Read implementations (decoder wrapping decoder)
    // - ROT13 applied twice returns to original text (it's its own inverse)
    // - The Read trait contract: must fill buffer and return bytes read
}
