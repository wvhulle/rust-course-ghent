{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slide-theme = {
      url = "git+https://codeberg.org/wvhulle/slide-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };

    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      nixpkgs,
      fenix,
      typix,
      slide-theme,
      typst-packages,
      crane,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      rustToolchain = fenix.packages.${system}.fromToolchainFile {
        file = ./rust-toolchain.toml;
        sha256 = "sha256-SDu4snEWjuZU475PERvu+iO50Mi39KVjqCeJeNvpguU=";
      };

      # Typst slide building
      typixLib = typix.lib.${system};

      slideSrc = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions (map (s: ./${s}) sessions);
      };

      buildSlides =
        session:
        let
          pdf = typixLib.buildTypstProject {
            src = slideSrc;
            typstSource = "${session}/slides.typ";
            typstOpts.root = ".";
            fontPaths = [ "${slide-theme.packages.${system}.fonts}/share/fonts" ];
            TYPST_PACKAGE_PATH = "${slide-theme.packages.${system}.typstPackagePath}";
            TYPST_PACKAGE_CACHE_PATH = "${typst-packages}/packages";
          };
        in
        pkgs.runCommand "${session}-slides" { } ''
          mkdir -p $out
          cp ${pdf} $out/${session}-slides.pdf
        '';

      sessions = [
        "session1"
        "session2"
        "session3"
        "session4"
        "session5"
        "session6"
        "session7"
      ];

      slidePackages = lib.listToAttrs (
        map (s: {
          name = "${s}-slides";
          value = buildSlides s;
        }) sessions
      );

      # Rust workspace building
      craneLib = (crane.mkLib pkgs).overrideToolchain (_: rustToolchain);
      craneSource = craneLib.cleanCargoSource ./.;

      commonArgs = {
        src = craneSource;
        pname = "rust-course-ghent";
        version = "0.1.0";
        strictDeps = true;
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl ];
      };

      # Only verify that dependencies resolve and lock file is up-to-date;
      # individual session code includes intentionally incomplete exercises.
      workspace = craneLib.buildDepsOnly commonArgs;

    in
    {

      packages.${system} =
        let
          allSlides = pkgs.symlinkJoin {
            name = "all-slides";
            paths = lib.attrValues slidePackages;
          };
        in
        slidePackages
        // {
          all-slides = allSlides;
          inherit workspace;
          default = allSlides;
        };

      checks.${system} = {
        workspace-deps = workspace;
      };

      devShells.${system}.default = craneLib.devShell {
        inputsFrom = [ workspace ];
        packages = [ pkgs.typst ];

        LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.openssl ];

        TYPST_PACKAGE_PATH = "${slide-theme.packages.${system}.typstPackagePath}";
        TYPST_FONT_PATHS = "${slide-theme.packages.${system}.fonts}/share/fonts";
      };
    };
}
