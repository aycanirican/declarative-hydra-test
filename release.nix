{ nixpkgs
}:

let 
  pkgs = import nixpkgs {};
  jobs = {
    package = pkgs.stdenv.mkDerivation {
      name = "declarative";
      src = ./.;
      buildPhase = "echo hello > README.md";

      installPhase = ''
        mkdir -p $out
        cp README.md $out
      '';
    };
  };

in jobs
