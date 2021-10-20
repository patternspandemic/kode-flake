# Kode additions:
# - krafix
# - kraffiti
# - kmake
# - Kha
# - KodeStudio
# - Krom ?

# Move samples to separate flake.

{
  description = "Kode Frameworks and Tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
#    devshell.url = "github:numtide/devshell/master";

    kinc-src = { url = "github:Kode/Kinc"; flake = false; };
    krafix-bin = { url = "github:Kode/krafix_bin"; flake = false; };
    kinc-shader-src = { url = "github:Kinc-Samples/Shader-Kinc"; flake = false; };
    kinc-texture-src = { url = "github:Kinc-Samples/Texture-Kinc"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, kinc-src, krafix-bin, kinc-shader-src, kinc-texture-src }:
    {
      overlay = import ./overlay.nix { inherit kinc-src krafix-bin kinc-shader-src kinc-texture-src; };
    }
    //
    (
      flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              #allowBroken = true;
              allowUnfree = true;
            };
            overlays = [
#              devshell.overlay
              self.overlay
            ];
          };
        in rec
        {
#          legacyPackages = pkgs.kode;

          packages = flake-utils.lib.flattenTree pkgs.kode;

          # apps.x86_64-linux = {
          #   krafix = { type = "app"; program = "${self.packages.x86_64-linux.krafix}/bin/krafix"; };
          #   kinc-shader = { type = "app"; program = "${self.packages.x86_64-linux.kinc-shader}/bin/kinc-shader"; };
          #   kinc-texture = { type = "app"; program = "${self.packages.x86_64-linux.kinc-texture}/bin/kinc-texture"; };
          # };
          apps.krafix = flake-utils.lib.mkApp { drv = packages.krafix; };
          apps.kinc-shader = flake-utils.lib.mkApp { drv = packages.kinc-shader; };
          apps.kinc-texture = flake-utils.lib.mkApp { drv = packages.kinc-texture; };

#          devShell = import ./devshell.nix { inherit pkgs; };

          checks = { };
        }
      )
    );
}
