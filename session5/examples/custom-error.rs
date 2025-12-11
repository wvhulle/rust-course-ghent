//! You are loading data files from the filesystem and validating them. Create your own custom error enum and variants to represent the different errors. Include metadata in the variants and check crash behaviour.
//!

fn load_from_file(path: &str) -> Result<String, std::io::Error> {
    std::fs::read_to_string(path)
}

/// This error enum only applies to the validation step.
/// You will need to create your own custom error enum that includes this.
enum ValidationError {
    EmptyData,
    InvalidCharacters(String),
}

fn validate_data(data: &str) -> Result<(), ValidationError> {
    if data.is_empty() {
        return Err(ValidationError::EmptyData);
    }
    if !data
        .chars()
        .all(|c| c.is_alphanumeric() || c.is_whitespace())
    {
        return Err(ValidationError::InvalidCharacters(data.to_string()));
    }
    Ok(())
}

/// Add variants with metadata as needed.
pub enum AppError {}

fn main() {
    todo!(
        "Load some files and validate them, handling errors appropriately with a general custom error enum."
    );
}
