{ declInput, branches }:

let pkgs = (import <nixpkgs> {});
    branches' = builtins.trace branches (builtins.fromJSON branches);
    branchNames = map (i: i.name) branches';

    mkJobsetsFromBranch = branch: ''
      "declarative-${branch}": {
        ${boilerplate},
        "description": "declarative ${branch}",
        "nixexprinput": "declarative",
        "nixexprpath": "release.nix",
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
      "declarative": { "type": "git", "value": "git@github.com:aycanirican/declarative-hydra-test ${branch}", "emailresponsible": false }
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
    

