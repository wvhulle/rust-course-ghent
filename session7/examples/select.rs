use tokio::time::{Duration, sleep};

async fn fetch_data() -> String {
    sleep(Duration::from_secs(5)).await;
    "Data fetched".to_string()
}

#[tokio::main]
async fn main() {
    // TODO: Use tokio::select! to race fetch_data() against a 2-second timeout
    // Print "Success: {data}" if fetch completes
    // Print "Timeout!" if the timeout occurs first

    // Hint: Use sleep(Duration::from_secs(2)) for the timeout branch

    let result = fetch_data().await;
    println!("Success: {result}");
}
