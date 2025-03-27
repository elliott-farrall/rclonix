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
      X-SwitchMethod = "stop-start";
    };
    Service = {
      Type = "notify";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.programs.rclone.mount-path}/${name}";
      ExecStart = "${pkgs.rclone}/bin/rclone mount ${name}:${path} ${config.programs.rclone.mount-path}/${name} --allow-other --file-perms 0777 --vfs-cache-mode writes";
      ExecStop = "/run/wrappers/bin/fusermount -u ${config.programs.rclone.mount-path}/${name}";
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
      Description = "Mount for ${config.programs.rclone.mount-path}/${name}";
      # After = [ "network-online.target" ];
    };
    Mount = {
      Type = "fuse.rclonefs";
      What = "${name}:${path}";
      Where = "${config.programs.rclone.mount-path}/${name}";
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
      Description = "Automount for ${config.programs.rclone.mount-path}/${name}";
      # After = [ "network-online.target" ];
      Before = [ "remote-fs.target" ];
    };
    Automount = {
      Where = "${config.programs.rclone.mount-path}/${name}";
      TimeoutIdleSec = 600;
    };
    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };
}