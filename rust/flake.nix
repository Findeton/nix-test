# This file is pretty general, and you can adapt it in your project replacing
# only `name` and `description` below.


{
  description = "Test rust code";

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
          
          rust-system = pkgs.rust-bin.stable.latest.default;
          # see https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md#importing-a-cargolock-file-importing-a-cargolock-file
          cargoPatches = {
              cargoLock = let
                  fixupLockFile = path: (builtins.readFile path);
              in {
                lockFileContents = fixupLockFile ./Cargo.lock.copy;
                  outputHashes = {};
              };
              postPatch = ''
                  cp ${./Cargo.lock.copy} Cargo.lock
              '';
          };
          buildRustPackageWithCargo = cargoArgs: pkgs.rustPlatform.buildRustPackage (cargoPatches // cargoArgs);

        # resulting packages of the flake
        in rec {
          packages.nix-test-rust = buildRustPackageWithCargo {
            pname = "nix-test-rust"; 
            version = "0.0.1";
            src = ./.;
            buildInputs = [
              #pkgs.darwin.apple_sdk.frameworks.Security
              pkgs.openssl
              rust-system 
            ];
            nativeBuildInputs = [
              pkgs.m4
            ];
          };
          # braid is the default package
          defaultPackage = packages.nix-test-rust;

          # configure the dev shell
          devShell = (
            pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }
          ) { 
            buildInputs = 
              packages.braid.buildInputs ++
              [ pkgs.bash ]; 
          };
        }
    );
}