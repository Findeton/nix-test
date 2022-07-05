{
  description = "Minimal rust wasm32-unknown-unknown example";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
# x86_64-pc-linux-gnu
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { 
          inherit system overlays;
        };
        stdenv = pkgs.clangStdenv;
        rust-nightly = pkgs
          .rust-bin
          .nightly
          ."2022-04-07"
          .default
          .override {
              extensions = [ "rust-src" ];
              targets = [ "wasm32-unknown-unknown" ];
          }
        ;
      in rec {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "rust-wasm";
          version = "0.0.1";
          src = ./.;
          nativeBuildInputs = [
            rust-nightly
            pkgs.nodePackages.npm
            pkgs.wasm-pack
            pkgs.wasm-bindgen-cli
          ];
          buildPhase = ''
            echo 'Build: flags'
            echo 'Build: wasm-pack build'
            wasm-pack build --mode no-install --out-name index --release --target web --features=wasm
            echo 'Build: wasm-pack pack'
            ls -lah pkg
            
          '';
          installPhase = "wasm-pack -v pack .";

          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };

        # configure the dev shell
        devShell = (
          pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }
        ) { 
          buildInputs = 
            defaultPackage.nativeBuildInputs ++
            [ pkgs.bash ]; 
        };
      }
    );
}
