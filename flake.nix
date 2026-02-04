{
  description = "Dotfiles management tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forEachSystem =
        supportedSystems: fn:
        lib.genAttrs supportedSystems (
          system:
          fn {
            inherit system;
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      # +------------- development shells -------------+

      devShells = forEachSystem systems (
        { system, pkgs, ... }@args:
        {
          default = self.devShells.${system}.dev;
          dev = pkgs.mkShell {
            name = "dotfiles";
            buildInputs = with pkgs; [
              bitwarden-cli
              chezmoi
            ];
          };
        }
      );
    };
}