{ lib
, config
, ...
}@args:

with lib;
let
  cfg = config.programs.rclone;
in 
{
  options.programs.rclone = {
    mount-path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}.config/rclone/mnt";
      description = "The path to mount rclone remotes.";
    };
    remotes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.path = mkOption {
          type = types.str;
          default = "/";
          description = "The path to mount the remote.";
        };
      });
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = attrsets.mapAttrs' (name: value: attrsets.nameValuePair
      "rclonix-${name}"
      (rclonix.mkService args { inherit name; inherit (value) path; })
    ) cfg.remotes;

    # systemd.user.mounts = attrsets.mapAttrs' (name: value: attrsets.nameValuePair
    #   (removePrefix "-" (replaceStrings ["/" ] [ "-" ] "${config.rclone.path}/${name}"))
    #   (rclonix.mkMount args { inherit name; })
    # ) cfg.remotes;

    # systemd.user.automounts = attrsets.mapAttrs' (name: value: attrsets.nameValuePair
    #   (removePrefix "-" (replaceStrings ["/" ] [ "-" ] "${config.rclone.path}/${name}"))
    #   (rclonix..mkAutoMount args { inherit name; })
    # ) cfg.remotes;
  };
}