// Let’s design a simple logging utility, using a trait Logger with a log method. Code that might log its progress can then take an &impl Logger. In testing, this might put messages in the test logfile, while in a production build it would send messages to a log server.

// However, the StderrLogger given below logs all messages, regardless of verbosity. Your task is to write a VerbosityFilter type that will ignore messages above a maximum verbosity.

// This is a common pattern: a struct wrapping a trait implementation and implementing that same trait, adding behavior in the process. In the “Generics” segment, we will see how to make the wrapper generic over the wrapped type.

trait Logger {
    /// Log a message at the given verbosity level.
    fn log(&self, verbosity: u8, message: &str);
}

struct StderrLogger;

impl Logger for StderrLogger {
    fn log(&self, verbosity: u8, message: &str) {
        eprintln!("verbosity={verbosity}: {message}");
    }
}

/// Only log messages up to the given verbosity level.
struct VerbosityFilter {
    max_verbosity: u8,
    inner: StderrLogger,
}

// TODO: Implement the `Logger` trait for `VerbosityFilter`.

fn main() {
    let logger = VerbosityFilter {
        max_verbosity: 3,
        inner: StderrLogger,
    };
    // TODO: test the logger
    // logger.log(5, "FYI");
    // logger.log(2, "Uhoh");
}
