#import "../template/lib.typ": *
#import "@preview/cetz:0.4.2"


#show: rust-course.with(
  config-info(
    title: [Lecture 7: Asynchronous programming],
    subtitle: [Presentations students, introduction to async],
    author: [Willem Vanhulle],
    date: [Tuesday December 9, 2025],
    institution: [DevLab Rust 2025],
    url: "https://github.com/wvhulle/rust-course-ghent",
  ),
  diagram-enabled: true,
  enable-qr-codes: false,
)


#title-slide()

= Presentations students

Students will present their work.

= Asynchronous programming

== Thread parking

Let's assume you have access to threads.

#info[For this presentation we will assume a standard desktop operating system.]

Threads can be "parked".




== Unparking threads

However, the thread itself needs to call thread::park() and then the spawning thread needs to save the join handle and call unpark on the join handle later on.


== Thread management

This requires a lot of bookkeeping by the developer.

- needs to think about how many threads do I need
- which threads are parked and need to be unparked
- i need to take data from one thread from the join handle and move it into a new thread

Very often we don't actually need full-blown threads.

Threads are good for problems that need to be solve in parallel.

== Parallelism or something else?

Real parallelism means two different processes can run completely independently.

Think about what kind of problems are truly parallel in real-life?


That is quite rare.

Usually they should start and end at the same time.

== Synchronisation

Many parallel task cannot be completed without synchronisation of shared state:

- Channels
- Mutexes
- Barriers


Very often the complexity of the code increases in parallel programming because of synchronisation and performance does not get any better.

== Concurrency with a metaphor

#definition[Concurrency is the ability to advance multiple tasks simultaneously.]

#qa[Why do managers do micromanagement?][They want to reduce risk and lack of control. They want to save money on developers and have more money in their pocket. Developers may *get sick or leave together with their knowledge*.]

They do not trust their employees.

Similarly a developer might want to spawn several processes or thread.

Sometimes it is better not to do micromanagement.

#qa[What is a way to solve the issues caused by micro-management?][Give more responsibility to your developers.]

== Back to code


Similarly, let your threads in your large application talk to eachother.

In asynchronous programming and in developer teams means saying "i am stuck".

#fletcher-diagram(
  node((0, 3), name: <human-line-bottom>, []),
  node((0, 0), name: <human-line-top>, []),
  edge(<human-line-top>, <human-line-bottom>, "-"),
  pause,
  node((2, 3), name: <thread-line-bottom>, []),
  node((2, 0), name: <thread-line-top>, []),
  edge(<thread-line-top>, <thread-line-bottom>, "-"),
)

So asynchronous programming is just multiple threads of computation working cooperatively and telling eachother when they get stuck.

By telling eachother when they get stuck, other threads can jump in and spend precious compute time.

Similarly, a good boss would not halt the whole company because of one team under-performing.



== Coroutines

Coroutines are functions that may yield an intermediate result.

Asynchronous functions in Rust are a special case.

The runtime model of async functions is equivalent to and implement by state machines.

== What Rust does differently

The state machines are by default allocated on the stack. When the state machine goes to the next state, the async runtime does not move the state machine.

In terms of code, this means that local variables in async functions before the await are not moved anyway.

In other languages the Runtime has to copy the whole set of local variables to another location in RAM memory to be able to run another async function. This less efficient.





= Declarative Rust

== Rust tooling

Pinning Rust version in `rust-toolchain.toml`:

```toml
[toolchain]
channel = "1.91"
components = ["rustfmt", "clippy", "rust-analyzer", "rust-src"]
```

In NixOS:

```nix
fenix = {
    url = "github:nix-community/fenix";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
rustToolchain = fenix.packages.x86_64-linux.fromToolchainFile {
    file = ./rust-toolchain.toml;
    sha256 = "sha256-SDu4snEWjuZU475PERvu+iO50Mi39KVjqCeJeNvpguU=";
};
```

```nix
pkgs.mkShell {
    nativeBuildInputs = [
    pkgs.pkg-config
    rustToolchain
    ];

    buildInputs = [
    pkgs.openssl
    ];

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];

    shellHook = ''
    echo "Welcome to the Rust course!"
    '';
};
```
