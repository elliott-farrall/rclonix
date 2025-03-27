{
  description = "Configure rclone using nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;
    snowfall.namespace = "rclonix";
    alias.modules = {
      home.default = "rclonix";
    };
  };
}