{ prsJSON, nixpkgs, src }:

let _pkgs = (import nixpkgs {});
    stableNixpkgs = "https://github.com/NixOS/nixpkgs-channels.git nixos-17.03";
    prs = builtins.fromJSON (builtins.readFile prsJSON);

    mkInputs = info: baseNixpkgs: ''
      "src":     { "type": "git", "value": "https://github.com/${info.head.repo.owner.login}/${info.head.repo.name}.git ${info.head.ref}", "emailresponsible": false },
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
     
    PRToJobset = num: info: ''
      "PR-${num}": {
        ${boilerplate},
        "description": "#${num}",
        "nixexprinput": "src",
        "nixexprpath": "nix/hydra.nix",
        "inputs": {
          ${mkInputs info stableNixpkgs}
        }
      }
    '';

    jobsets = _pkgs.lib.mapAttrs (num: info: PRToJobset num info) prs;

in {
  jobsets = _pkgs.writeText "jobsets.json" (builtins.toJSON jobsets);
}
    

