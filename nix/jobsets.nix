{ nixpkgs, declInput, branches }:

let pkgs = (import nixpkgs {});
    branches' = builtins.trace branches (builtins.fromJSON branches);
    branchNames = map (i: i.name) branches';

    branchToJobset = branch: ''
      "declarative-${branch}": {
        ${boilerplate},
        "description": "declarative ${branch}",
        "nixexprinput": "src",
        "nixexprpath": "hydra.nix",
        "inputs": {
          ${mkInputs branch}
        }
      }
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

    mkInputs = branch: ''
      "src": { "type": "git", "value": "https://github.com/aycanirican/declarative-hydra-test.git ${branch}", "emailresponsible": false }
      "nixpkgs": { "type": "git", "value": "https://github.com/NixOS/nixpkgs-channels.git nixos-16.09", "emailresponsible": false }
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
    

