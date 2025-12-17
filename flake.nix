{
  description = "Rust course - Ghent";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      git-hooks,
      treefmt-nix,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = ./rust-toolchain.toml;
        sha256 = "sha256-SDu4snEWjuZU475PERvu+iO50Mi39KVjqCeJeNvpguU=";
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";

        programs = {
          nixfmt.enable = true;
          prettier = {
            enable = true;
            includes = [ "*.md" ];
          };
          typstyle.enable = true;
          rustfmt = {
            enable = true;
            package = rustToolchain;
          };
        };

        settings.global.excludes = [
          "target/*"
          "*.lock"
          ".direnv/*"
        ];
      };

      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          cspell = {
            enable = false;
            name = "cspell";
            description = "Check spelling with cspell";
            entry = "${pkgs.cspell}/bin/cspell lint --no-progress --no-summary";
            types = [ "text" ];
          };
          typos = {
            enable = true;
          };
          typstyle = {
            enable = true;
          };
          rustfmt = {
            enable = true;
            packageOverrides.rustfmt = rustToolchain;
            packageOverrides.cargo = rustToolchain;
          };
          clippy = {
            enable = false;
            packageOverrides.clippy = rustToolchain;
            packageOverrides.cargo = rustToolchain;
            settings.allFeatures = true;
          };
          nixfmt = {
            enable = true;
          };
        };
      };
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system} = {
        inherit pre-commit-check;
        formatting = treefmtEval.config.build.check self;
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;

        nativeBuildInputs = [
          pkgs.pkg-config
          rustToolchain
        ]
        ++ pre-commit-check.enabledPackages;

        buildInputs = [
          pkgs.openssl
        ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];
      };
    };
}
