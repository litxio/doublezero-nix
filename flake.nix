{
  description = "DoubleZero client and CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        doublezero = pkgs.callPackage ./default.nix { };
      in
      {
        packages = {
          default = doublezero;
          doublezero = doublezero;
        };

        apps.default = flake-utils.lib.mkApp {
          drv = doublezero;
          exePath = "/bin/doublezero";
        };
      }
    );
}
