{
  description = "Kode Frameworks and Tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
#    devshell.url = "github:numtide/devshell/master";

    kinc-src = { url = "github:Kode/Kinc"; flake = false; };
    kinc-shader-src = { url = "github:Kinc-Samples/Shader-Kinc"; flake = false; };
    kinc-texture-src = { url = "github:Kinc-Samples/Texture-Kinc"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, kinc-src, kinc-shader-src, kinc-texture-src }:
    {
      overlay = import ./overlay.nix { inherit kinc-src kinc-shader-src kinc-texture-src; };
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
          #   kinc-shader = { type = "app"; program = "${self.packages.x86_64-linux.kinc-shader}/bin/kinc-shader"; };
          #   kinc-texture = { type = "app"; program = "${self.packages.x86_64-linux.kinc-texture}/bin/kinc-texture"; };
          # };
          apps.kinc-shader = flake-utils.lib.mkApp { drv = packages.kinc-shader; };
          apps.kinc-texture = flake-utils.lib.mkApp { drv = packages.kinc-texture; };

#          devShell = import ./devshell.nix { inherit pkgs; };

          checks = { };
        }
      )
    );
}
