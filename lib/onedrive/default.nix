{ lib
, ...
}:

with lib;
{
  types.onedrive = types.submodule ({ name, config, ... }: {
    options = {
      type = rclonix.mkTypeOption "onedrive";
      name = rclonix.mkNameOption;
      secrets = rclonix.mkSecretsOption;
      config = rclonix.mkConfigOption;
      path = rclonix.mkPathOption;

      token = rclonix.mkSecretOption "token";
      drive_id = rclonix.mkSecretOption "drive_id";
      drive_type = mkOption {
        type = types.enum [ "personal" "business" ];
        default = "personal";
      };
    };
    config = {
      inherit name;
      secrets = with config; [ token drive_id ];

      config = ''
        [${config.name}]
        type = ${config.type}
        token = @${config.token}@
        drive_id = @${config.drive_id}@
        drive_type = ${config.drive_type}
      '';
    };
  });
}