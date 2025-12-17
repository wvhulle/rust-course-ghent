use futures::stream::{self, StreamExt};

#[tokio::main]
async fn main() {
    let numbers = stream::iter(1..=20);

    // TODO: Chain filter, map, and take adapters to:
    // 1. Filter out numbers less than 5
    // 2. Square each number
    // 3. Take only the first 3 results
    //
    // Expected output: [25, 36, 49]

    let result: Vec<_> = numbers.collect().await;
    println!("{result:?}");
}
