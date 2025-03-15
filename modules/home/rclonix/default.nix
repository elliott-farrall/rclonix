{ lib
, config
, ...
}@args:

with lib;
let
  cfg = config.rclone;
  cfg-path = ".config/rclone/rclone.conf";

  secrets = concatLists (attrsets.mapAttrsToList (name: value: value.secrets) cfg.remotes); 
in 
{
  options.rclone = {
    enable = mkEnableOption "rclone configuration via rclonix";

    path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}.config/rclone/mnt";
      description = "The path to mount rclone remotes.";
    };

    remotes = mkOption {
      type = types.attrsOf (rclonix.taggedSubmodules { inherit (rclonix) types; });
      default = {};
      description = "A map of rclone remotes to configure.";
    };
  };
  config = mkIf cfg.enable {
    age.secrets = attrsets.genAttrs secrets (name: { substitutions = [ "${config.home.homeDirectory}/${cfg-path}" ]; });

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

    home.file.${cfg-path} = {
      text = concatLines (attrsets.mapAttrsToList (name: value: value.config) cfg.remotes);
      force = true;
    };
  };
}