{
  description = "An over-engineered nix test";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/21.05";

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      # Notice the reference to nixpkgs here.
      with import nixpkgs { system = "x86_64-linux"; };
      clangStdenv.mkDerivation {
          name = "nix-test";
          src = self;
          buildPhase = "cd cpp && clang++ -Wall -std=c++11 main.cpp -o nix-test";
          installPhase = "mkdir -p $out/bin; install -t $out/bin nix-test";
          buildInputs = [ clang ];
      };

  };
}
