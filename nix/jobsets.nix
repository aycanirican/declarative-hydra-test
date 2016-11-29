{ nixpkgs, declInput, branches }:

let pkgs = (import nixpkgs {});
    stableNixpkgs = "https://github.com/NixOS/nixpkgs-channels.git nixos-16-09";
    upstreamNixpkgs   = "https://github.com/NixOS/nixpkgs.git";

    branches' = builtins.trace branches (builtins.fromJSON branches);
    branchNames = map (i: i.name) branches';

    mkInputs = branch: baseNixpkgs: ''
      "src":     { "type": "git", "value": "https://github.com/aycanirican/declarative-hydra-test.git ${branch}", "emailresponsible": false },
      "nixpkgs": { "type": "git", "value": "${baseNixpkgs}", "emailresponsible": false }
    '';

    boilerplate = ''
      "enabled": 1,
      "hidden": false,
      "checkinterval": 5,
      "schedulingshares": 100,
      "enableemail": false,
      "emailoverride": "",
      "keepnr": 1
    '';

    branchToJobset = branch: ''
      "${branch}-stable": {
        ${boilerplate},
        "description": "Branch with stable nixpkgs: ${branch}",
        "nixexprinput": "src",
        "nixexprpath": "nix/hydra.nix",
        "inputs": {
          ${mkInputs branch stableNixpkgs}
        }
      },
      "${branch}-unstable": {
        ${boilerplate},
        "description": "Branch with unstable nixpkgs: ${branch}",
        "nixexprinput": "src",
        "nixexprpath": "nix/hydra.nix",
        "inputs": {
          ${mkInputs branch upstreamNixpkgs}
        }
      }
    '';

    jobsetBranches = pkgs.lib.concatMapStringsSep "," branchToJobset branchNames;

in {
  jobsets = pkgs.runCommand "spec.json-jobsets" { preferLocalBuild=true; } ''
    cat <<EOF
      ${builtins.toJSON branches'}
    EOF
    cat > $out <<EOF
    {
      ${jobsetBranches}
    }
    EOF
  '';
}
    

