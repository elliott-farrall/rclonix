# Rclonix

A module to configure [rclone](https://rclone.org/) using [Home-Manager](https://github.com/nix-community/home-manager).

### Install

The Home-Manager module is available to install via flakes by importing the flake output `homeManagerModules.default`.

Secret management for remotes will be done using [agenix](https://github.com/ryantm/agenix) and [agenix-substitutes](https://github.com/elliott-farrall/agenix-substitutes) so both of these must be installed.

### Usage

To enable the use of this module set `rclone.enable = true` and configure `rclone.path` to the absolute path of the directory where you wish to mount your remotes.

Remotes are then configured like:
```nix
{
    rclone.remotes.dropbox-example = {
        type = "dropbox";
        token = "dropbox-token";
        path = "/Documents";
    };

    age.secrets.dropbox-token.file = ./token.age;
}
```
Depending on the remote `type`, different options will be available that match those from `rclone.conf`. The `path` option refers to the path on the remote that should be mounted.

Rclonix adds the relevant entries to `rclone.conf` and creates systemd units to automatically mount the remotes to your local filesystem.

### Contributing

The Home-Manager module currently only supports a small subset of the remotes and options supported by rclone.

To add a new remote of type `example-type`, create a file `lib/example-type/default.nix` and use the following template:
```nix
{ lib
, ...
}:

with lib;
{
  types.exaple-type = types.submodule ({ name, config, ... }: {
    options = {
      type = rclonix.mkTypeOption "example-type";
      name = rclonix.mkNameOption;
      secrets = rclonix.mkSecretsOption;
      config = rclonix.mkConfigOption;
      path = rclonix.mkPathOption;

      token1 = rclonix.mkSecretOption "token1";
      token2 = rclonix.mkSecretOption "token2";
    };
    config = {
      inherit name;
      secrets = with config; [ token1 token2 ];

      config = ''
        [${config.name}]
        type = ${config.type}
        token1 = @${config.token1}@
        token2 = @${config.token2}@
      '';
    };
  });
}
```
Missing remote options can also be added.

### Planned Features

- A NixOS module.
- Make use of `systemd.mount` and `systemd.automount`.
- More remotes and options...