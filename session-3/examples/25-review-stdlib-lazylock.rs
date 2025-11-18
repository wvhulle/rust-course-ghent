//! Discover when LazyLock is actually needed
//!
//! Start with what seems like a good use case, then find simpler solutions

use std::sync::LazyLock;

// Scenario: You're building a web server that needs a version banner

// Attempt 1: Use LazyLock for the version string
// Uncomment to try:
//
// static VERSION: LazyLock<String> = LazyLock::new(|| {
//     format!("MyApp v{}", env!("CARGO_PKG_VERSION"))
// });
//
// fn get_version() -> &'static str {
//     &VERSION
// }

// Discovery: You don't need LazyLock for compile-time values!
const VERSION: &str = env!("CARGO_PKG_VERSION");

fn get_version() -> &'static str {
    VERSION
}

fn format_banner() -> String {
    todo!("Return 'MyApp vVERSION' using the VERSION const and format!")
}

// Attempt 2: LazyLock for formatted banner
// Uncomment to try:
//
// static BANNER: LazyLock<String> = LazyLock::new(|| {
//     format!("===== MyApp v{} =====", env!("CARGO_PKG_VERSION"))
// });
//
// fn get_banner() -> &'static str {
//     &BANNER
// }

// Discovery: You don't need static for simple formatting!
fn get_banner() -> String {
    format!("===== MyApp v{} =====", env!("CARGO_PKG_VERSION"))
}

// Attempt 3: Try using const fn for formatting
// Uncomment to see the limitation:
//
// const fn get_banner_const() -> &'static str {
//     format!("===== MyApp v{} =====", env!("CARGO_PKG_VERSION"))
// }

// Discovery: const fn can't use format!, but that's okay - just use a regular function!

// Real use case: Runtime configuration not known at compile time
// This is where LazyLock actually shines!

static CONFIG_PATH: LazyLock<String> = LazyLock::new(|| {
    println!("Loading CONFIG_PATH (happens once, on first access)");
    std::env::var("CONFIG_PATH").unwrap_or_else(|_| {
        println!("CONFIG_PATH not set, using default");
        "config.toml".to_string()
    })
});

static DATABASE_URL: LazyLock<String> = LazyLock::new(|| {
    println!("Loading DATABASE_URL (happens once, on first access)");
    std::env::var("DATABASE_URL").unwrap_or_else(|_| {
        println!("DATABASE_URL not set, using in-memory database");
        "sqlite::memory:".to_string()
    })
});

fn get_config_path() -> &'static str {
    &CONFIG_PATH
}

fn get_database_url() -> &'static str {
    &DATABASE_URL
}

// Exercise: Create LazyLock for log level
// static LOG_LEVEL: LazyLock<String> = LazyLock::new(|| {
//     todo!("Read LOG_LEVEL env var with std::env::var, default to 'info'");
// });

// fn get_log_level() -> &'static str {
//     todo!("Return reference to LOG_LEVEL");
// }

fn demonstrate_runtime_config() {
    println!("=== Runtime Configuration ===");
    println!("Config path: {}", get_config_path());
    println!("Database URL: {}", get_database_url());

    todo!("Uncomment get_log_level() call and implement LOG_LEVEL");
    // println!("Log level: {}", get_log_level());
}

fn main() {
    println!("=== The LazyLock Trap ===");
    println!("Version: {}", get_version());

    todo!("Implement format_banner() and print it");

    todo!("Uncomment Attempt 1 - LazyLock for version string");
    todo!("Notice: LazyLock adds complexity for compile-time known values");
    todo!("Compare with const VERSION - which is simpler?");

    todo!("Uncomment Attempt 2 - LazyLock for formatted banner");
    todo!("Do you really need &'static str? Regular String from function works fine!");

    todo!("Uncomment Attempt 3 - try const fn with format!");
    todo!("Realize: const fn is limited, but regular fn is perfectly fine");

    println!("\n=== When LazyLock IS Actually Needed ===");
    demonstrate_runtime_config();

    println!("\n=== Try This ===");
    println!("1. Run without setting environment variables");
    println!("2. Set CONFIG_PATH: export CONFIG_PATH=/etc/myapp/config.toml");
    println!("3. Set DATABASE_URL: export DATABASE_URL=postgres://localhost/mydb");
    println!("4. Run again and see LazyLock load runtime values");

    // Use LazyLock ONLY when:
    //   - Value comes from runtime (env vars, files, user input)
    //   - Expensive initialization (regex compilation, parsing)
    //   - Must be global and lazily initialized
    //
    // Don't use LazyLock for:
    //   - Compile-time known values (use const)
    //   - Simple formatting (use regular functions)
    //   - Local state (use local variables)
}
