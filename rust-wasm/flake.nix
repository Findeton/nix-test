{
  description = "Flake for rust-wasm";

  # input
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # output function of this flake
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let 
          overlays = [ (import rust-overlay) ];
          # pkgs is just the nix packages
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rust-nightly = pkgs
            .rust-bin
            .selectLatestNightlyWith(
              toolchain: toolchain.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              }
            );

        # resulting packages of the flake
        in rec {
          # WIP Derivation for rust-wasm
          # Continue work here following https://srid.ca/rust-nix reference
          packages.rust-wasm = pkgs.clangStdenv.mkDerivation {
            name = "rust-wasm";
            version = "0.0.1";
            src = self;
            type = "git"; 
            submodules = "true";
            nativeBuildInputs = [
                rust-nightly
                pkgs.wasm-pack
                pkgs.wasm-bindgen-cli
                pkgs.libiconv
            ];
          buildPhase = ''
            cd rust-wasm
            echo 'Build: flags'
            export RUSTFLAGS='-C target-feature=+atomics,+bulk-memory,+mutable-globals'
            echo 'Build: wasm-pack build'
            wasm-pack build --out-name index --release --target web --features=wasm -- -Z build-std=panic_abort,std
            echo 'Build: wasm-pack pack'
            wasm-pack pack .
          '';
          installPhase = "echo 'Skipping installPhase'";
          };
          # rust-wasm is the default package
          defaultPackage = packages.rust-wasm;

          # configure the dev shell
          devShell = (
            pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }
          ) { 
            buildInputs = 
              packages.rust-wasm.nativeBuildInputs ++
              [ pkgs.bash ]; 
          };
        }
    );
}