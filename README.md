# DevLab Rust 2025

Evening lectures on Rust in Ghent Nov - Dec 2025 for experienced developers.

Registration is possible for the whole series or individual sessions that interest you: [on pretix.eu](https://pretix.eu/devlab/rust-course/). Do this several days in advance as the ticket shop closes.

View the topics covered: [course plan](./PLAN.md).

## Guidelines

Before the first class:

- Install Rust as explained in [rustup.rs/](https://rustup.rs/).
  - For Windows users: don't use `winget` or `chocolatey`
  - For Nix users: use fenix overlay and dev shell in [`flake.nix`](./flake.nix)
- Install any editor that supports `rust-analyzer` and compile a very simple "hello world" program to setup your system

Before every class:

- Avoid spending time setting up your network, cloning, pulling or installing during the session. The **time in sessions is very limited** and should be spent on Rust.
- Read the relevant chapters in the official Rust book about the previous and upcoming session.
- Finish important exercises and prepare questions. Feel free to ask for PR reviews.

During in-person sessions:

- Follow along with the presentation when new material arrives and ask questions
- Open the exercise files located in the `examples` or `tests` folder of session X.
- Turn of AI tools and read the assignment, try to solve, _ask for help anytime_

Test your (partial) solution:

- For examples with `main` in `examples/`: `cargo run --example fibonacci`
- For examples with `#[cfg(test)]` in `examples/`: `cargo test --example fibonacci`
