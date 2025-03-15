{ lib
, ...
}:

with lib;
{
  mkService = { pkgs, config, ... }:
    { name 
    , path ? "/"
    }: {
    Unit = {
      Description = "Mount for ${name}";
      After = [ "agenix-substitutes.service" ];
      Wants = [ "agenix-substitutes.service" ];
      X-SwitchMethod = "stop-start";
    };
    Service = {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.rclone.path}/${name}";
      ExecStart = "${pkgs.rclone}/bin/rclone mount ${name}:${path} ${config.rclone.path}/${name} --allow-other --file-perms 0777 --vfs-cache-mode writes --links";
      ExecStop = "/run/wrappers/bin/fusermount -u ${config.rclone.path}/${name}";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  mkMount = { pkgs, config, ... }: 
    { name 
    , path ? "/"
    }: {
    Unit = {
      Description = "Mount for ${config.rclone.path}/${name}";
      # After = [ "network-online.target" ];
    };
    Mount = {
      Type = "fuse.rclonefs";
      What = "${name}:${path}";
      Where = "${config.rclone.path}/${name}";
      Options = concatStringsSep "," [ "allow_other" "file_perms=0777" "vfs-cache-mode=writes" "links" ];
      ExecSearchPath = "/run/wrappers/bin/:${pkgs.rclone}/bin/";
    };
    Install = {
      # Since we are not using automount
      WantedBy = [ "default.target" ];
    };
  };

  mkAutoMount = { config, ... }:
    { name 
    }: {
    Unit = {
      Description = "Automount for ${config.rclone.path}/${name}";
      # After = [ "network-online.target" ];
      Before = [ "remote-fs.target" ];
    };
    Automount = {
      Where = "${config.rclone.path}/${name}";
      TimeoutIdleSec = 600;
    };
    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };

  mkTypeOption = type: mkOption {
    type = types.enum [ type ];
    default = type;
    internal = true;
  };
  mkNameOption = mkOption {
    type = types.str;
    internal = true;
  };
  mkConfigOption = mkOption {
    type = types.lines;
    internal = true;
  };
  mkPathOption = mkOption {
    type = types.path;
    default = "/";
  };
  mkSecretsOption = mkOption {
    type = types.listOf types.str;
    internal = true;
  };
  mkSecretOption = label: mkOption {
    type = types.str;
    description = "The name of the ${label} as declared in `age.secrets`.";
  };

  # https://github.com/NixOS/nixpkgs/pull/254790
  # A type that is one of several submodules, similiar to types.oneOf but is usable inside attrsOf or listOf
  # submodules need an option with a type str which is used to find the corresponding type
  taggedSubmodules =
    { types
    , specialArgs ? {}
    }: 
    mkOptionType {
      name = "taggedSubmodules";
      description = "one of ${concatStringsSep "," (attrNames types)}";
      check = x: if x ? type then types.${x.type}.check x else throw "No type option set in:\n${lib.generators.toPretty {} x}";
      merge = loc: foldl' (res: def: types.${def.value.type}.merge loc [
        (lib.recursiveUpdate { value._module.args = specialArgs; } def)
      ]) { };
      nestedTypes = types;
    };
}