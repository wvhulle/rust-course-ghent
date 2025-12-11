== Rust tooling

Pinning Rust version in `rust-toolchain.toml`:

```toml
[toolchain]
channel = "1.91"
components = ["rustfmt", "clippy", "rust-analyzer"]
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
