use futures::future::ready;
use futures::stream::{self, StreamExt};

#[tokio::main]
async fn main() {
    let numbers = stream::iter(1..=20);

    // Chain filter, map, and take adapters
    let result: Vec<_> = numbers
        .filter(|x| ready(*x >= 5))
        .map(|x| x * x)
        .take(3)
        .collect()
        .await;

    println!("{result:?}"); // [25, 36, 49]
}
