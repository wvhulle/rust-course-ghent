//! Compile-time vs runtime environment variables

fn demonstrate_compile_time() {
    // env! reads variables at compile time
    let build_profile = env!("PROFILE");
    dbg!(build_profile);

    // Uncomment to see compile error if variable doesn't exist:
    // let missing = env!("THIS_DOES_NOT_EXIST");
}

fn demonstrate_runtime() {
    // std::env::var reads variables at runtime and returns Result
    match std::env::var("HOME") {
        Ok(home) => dbg!(home),
        Err(e) => dbg!(e.to_string()),
    };
}

fn get_required_config() -> String {
    // TODO: Step 1: Use env! to read CARGO_PKG_NAME at compile time
    todo!("use env!");
}

fn get_optional_config() -> Option<String> {
    // TODO: Step 2: Use std::env::var to read USER at runtime
    todo!("use var");
    // TODO: Step 3: Convert Result to Option using .ok()
    todo!("convert type");
}

fn get_config_with_default() -> String {
    // TODO: Step 4: Read EDITOR runtime variable, default to 'vim' if missing
    todo!("use if");
    // TODO: Hint: Use unwrap_or_default() or unwrap_or()
    todo!("use unwrap_or");
}

// Attempt 1: Try to use env! for runtime variables
//
// fn try_runtime_with_compile_macro() {
//     let user = env!("USER");
//     dbg!(user);
// }

// Attempt 2: What if the compile-time variable is missing?
//
// fn try_missing_compile_var() {
//     let missing = env!("DEFINITELY_NOT_SET");
//     dbg!(missing);
// }

fn main() {
    demonstrate_compile_time();

    demonstrate_runtime();

    // TODO: Uncomment Attempt 1 - Can you use env! for USER?
    todo!("uncomment");
    // TODO: Uncomment Attempt 2 - What happens with missing compile vars?
    todo!("uncomment");

    dbg!(get_required_config());
    dbg!(get_optional_config());
    dbg!(get_config_with_default());

    // env! fails at compile time, std::env::var returns Result at runtime"
}
