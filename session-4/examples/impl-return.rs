//! How do lifetime captures change in Edition 2024 for `impl Trait` returns?

struct Wrapper {
    factor: i32,
}

// Edition 2024: lifetimes captured automatically (no `+ 'a` needed)
fn multiply_adapter(
    iter: impl Iterator<Item = i32>,
    factor: &Wrapper,
) -> impl Iterator<Item = i32> {
    iter.map(move |x| x * factor.factor)
}

// Explicit capture with `use<>` syntax (all type params must be listed)
fn multiply_explicit<'a, I: Iterator<Item = i32>>(
    iter: I,
    factor: &'a Wrapper,
) -> impl Iterator<Item = i32> + use<'a, I> {
    iter.map(move |x| x * factor.factor)
}

// Opt out of lifetime capture: `use<>` means 'static
fn static_iter() -> impl Iterator<Item = i32> + use<> {
    [1, 2, 3].into_iter()
}

// Pre-2024: explicit `+ 'a` was required
fn multiply_old_style<'a>(
    iter: impl Iterator<Item = i32> + 'a,
    factor: &'a Wrapper,
) -> impl Iterator<Item = i32> + 'a {
    iter.map(move |x| x * factor.factor)
}

fn main() {
    let wrapper = Wrapper { factor: 3 };
    let data = vec![1, 2, 3, 4, 5];

    dbg!(multiply_adapter(data.clone().into_iter(), &wrapper).collect::<Vec<_>>());
    dbg!(multiply_explicit(data.clone().into_iter(), &wrapper).collect::<Vec<_>>());
    dbg!(multiply_old_style(data.into_iter(), &wrapper).collect::<Vec<_>>());
    dbg!(static_iter().collect::<Vec<_>>());
}
