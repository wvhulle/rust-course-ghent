use tokio::time::{Duration, sleep};

async fn fetch_data() -> String {
    sleep(Duration::from_secs(5)).await;
    "Data fetched".to_string()
}

#[tokio::main]
async fn main() {
    // Using tokio::select! to race fetch_data() against a 2-second timeout
    tokio::select! {
        result = fetch_data() => {
            println!("Success: {result}");
        }
        _ = sleep(Duration::from_secs(2)) => {
            println!("Timeout!");
        }
    }
}
