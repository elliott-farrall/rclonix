# Rclonix

A module for mounting [rclone](https://rclone.org/) remotes using [Home-Manager](https://github.com/nix-community/home-manager).

### Install

The Home-Manager module is available to install via flakes by importing the flake output `homeManagerModules.default`.

It is assumed that the rclone remotes have already been configured in `programs.rclone.remotes` in Home-Manager.

### Usage

Stary by setting the path where you would like your remotes to be mounted in `programs.rclone.mount-path`. Then, for each remote, set `programs.rclone.remotes.<name>.path` to the path on the remote that you would like mounted (defaults to the root path).

Rclonix creates the relevant systemd units to automatically mount the remotes to your local filesystem.

### Planned Features

- A NixOS module.
- Make use of `systemd.mount` and `systemd.automount`.
