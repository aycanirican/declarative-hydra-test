{ nixpkgs }:

# nix-build hydra.nix --argstr nixpkgs /home/fxr/nixpkgs/

let 
  pkgs = import nixpkgs {};
in

with (import ./release.nix { inherit nixpkgs; }); {
  inherit package;
}
