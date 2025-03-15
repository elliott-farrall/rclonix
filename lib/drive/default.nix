{ lib
, ...
}:

with lib;
{
  types.drive = types.submodule ({ name, config, ... }: {
    options = {
      type = rclonix.mkTypeOption "drive";
      name = rclonix.mkNameOption;
      secrets = rclonix.mkSecretsOption;
      config = rclonix.mkConfigOption;
      path = rclonix.mkPathOption;

      token = rclonix.mkSecretOption "token";
    };
    config = {
      inherit name;
      secrets = with config; [ token ];

      config = ''
        [${config.name}]
        type = ${config.type}
        token = @${config.token}@
        team_drive =
      '';
    };
  });
}