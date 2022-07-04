{
  description = "Minimal rust wasm32-unknown-unknown example";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/69ca5c9898b26c2063d0e8a4db013e4ba0548159";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
# x86_64-pc-linux-gnu
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { 
          inherit system overlays;
          #crossSystem = {
          #  config = "wasm32-unknown-unknown";
          #  useLLVM = true;
          #};
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
            #pkgs.nodePackages.npm
            pkgs.yarn
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
