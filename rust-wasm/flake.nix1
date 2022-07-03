{
  description = "Minimal rust wasm32-unknown-unknown example";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; }; in
      {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "rust-wasm";
          version = "0.0.1";
          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
      }
    );
}
