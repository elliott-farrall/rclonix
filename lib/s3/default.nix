{ lib
, ...
}:

with lib;
{
  types.s3 = types.submodule ({ name, config, ... }: {
    options = {
      type = rclonix.mkTypeOption "s3";
      name = rclonix.mkNameOption;
      secrets = rclonix.mkSecretsOption;
      config = rclonix.mkConfigOption;
      path = rclonix.mkPathOption;

      provider = mkOption {
        type = types.enum [ "Cloudflare" ];
        default = "Cloudflare";
      };
      access_key_id = rclonix.mkSecretOption "access_key_id";
      secret_access_key = rclonix.mkSecretOption "secret_access_key";
      endpoint = rclonix.mkSecretOption "endpoint";
    };
    config = {
      inherit name;
      secrets = with config; [ access_key_id secret_access_key endpoint ];

      config = ''
        [${config.name}]
        type = ${config.type}
        provider = ${config.provider}
        access_key_id = @${config.access_key_id}@
        secret_access_key = @${config.secret_access_key}@
        endpoint = @${config.endpoint}@
        acl = private
      '';
    };
  });
}