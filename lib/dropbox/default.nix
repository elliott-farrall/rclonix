{ lib
, ...
}:

with lib;
{
  types.dropbox = types.submodule ({ name, config, ... }: {
    options = {
      type = rclonix.mkTypeOption "dropbox";
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
      '';
    };
  });
}