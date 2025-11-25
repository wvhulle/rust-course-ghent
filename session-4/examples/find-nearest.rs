#[derive(Debug)]
struct Point(i32, i32);

/// Searches `points` for the point closest to `query`.
/// Assumes there's at least one point in `points`.
fn find_nearest<'a>(points: &'a [Point], query: &Point) -> &'a Point {
    fn cab_distance(p1: &Point, p2: &Point) -> i32 {
        (p1.0 - p2.0).abs() + (p1.1 - p2.1).abs()
    }

    let mut nearest = None;
    for p in points {
        if let Some((_, nearest_dist)) = nearest {
            let dist = cab_distance(p, query);
            if dist < nearest_dist {
                nearest = Some((p, dist));
            }
        } else {
            nearest = Some((p, cab_distance(p, query)));
        };
    }

    nearest.map(|(p, _)| p).unwrap()
    // query // What happens if we do this instead?
}

fn main() {
    let points = &[Point(1, 0), Point(1, 0), Point(-1, 0), Point(0, -1)];
    let query = Point(0, 2);
    let nearest = find_nearest(points, &query);

    // `query` isn't borrowed at this point.
    drop(query);

    dbg!(nearest);
}
