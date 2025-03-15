{
  description = "Configure rclone using nix";

  inputs = {
    snowfall-lib.url = "github:snowfallorg/lib";
    nixpkgs.url = "github:nixos/nixpkgs";
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