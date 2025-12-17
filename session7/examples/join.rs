use tokio::time::{Duration, sleep};

async fn fetch_user(id: u32) -> String {
    sleep(Duration::from_millis(100)).await;
    format!("User {id}")
}

async fn fetch_posts(user_id: u32) -> Vec<String> {
    sleep(Duration::from_millis(150)).await;
    vec![
        format!("Post 1 by user {user_id}"),
        format!("Post 2 by user {user_id}"),
    ]
}

#[tokio::main]
async fn main() {
    // TODO: This code runs sequentially. Refactor it to use tokio::join!
    // to run both futures concurrently.

    let user = fetch_user(1).await;
    let posts = fetch_posts(1).await;

    println!("User: {user}");
    println!("Posts: {}", posts.len());
    for post in posts {
        println!("  - {post}");
    }
}
