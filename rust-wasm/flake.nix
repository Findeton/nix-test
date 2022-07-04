{
  description = "Minimal rust wasm32-unknown-unknown example";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
# x86_64-pc-linux-gnu
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { 
          inherit system overlays;
          crossSystem = {
            config = "wasm32-unknown-unknown";
            useLLVM = true;
          };
        };
        rust-nightly = pkgs
          .rust-bin
          .selectLatestNightlyWith(
            toolchain: toolchain.default.override {
              extensions = [ "rust-src" ];
              targets = [ "wasm32-unknown-unknown" ];
            }
        );
      in rec {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "rust-wasm";
          version = "0.0.1";
          src = ./.;
          nativeBuildInputs = [
            rust-nightly
            pkgs.wasm-pack
            pkgs.wasm-bindgen-cli
          ];
          buildPhase = ''
            echo 'Build: flags'
            export RUSTFLAGS='-C target-feature=+atomics,+bulk-memory,+mutable-globals'
            echo 'Build: wasm-pack build'
            wasm-pack build --out-name index --release --target web --features=wasm -- -Z build-std=panic_abort,std
            echo 'Build: wasm-pack pack'
            wasm-pack pack .
          '';

          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      }
    );
}
