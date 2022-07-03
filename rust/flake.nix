{
  description = "An over-engineered nix test";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/21.05";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, rust-overlay }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      clangStdenv.mkDerivation {
          name = "nix-test";
          src = self;
          buildPhase = "cd rust && cargo build";
          installPhase = "mkdir -p $out/bin; install -t $out/bin nix-test";
          nativeBuildInputs = [ rust-overlay ];
      };

  };
}
