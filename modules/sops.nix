{ pkgs
, config
, lib
, ...
}:
let
  cfg = config.custom;
in
{
  options = {
    custom.sops = {
      enable = lib.mkEnableOption "Enable sops";
      env_as_config.target_path = lib.mkOption {
        type = lib.types.str;
        default = "./config";
        description = "Path to save the unencrypted file.";
      };
      env_as_config.script = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs.sops}/bin/sops -d ${cfg.common.environment}.secrets.yaml > ${cfg.sops.env_as_config.target_path}/unencrypted_${cfg.common.environment}_secrets.yaml";
        description = "Populate secrets as a unencrypted file.";
      };
    };
  };
  config = lib.mkIf cfg.sops.enable
    {
      packages = [
        pkgs.sops
      ];

      scripts = {
        sops_populate_config.exec = ''
          echo "Populating environment secrets as config";
          ${cfg.sops.env_as_config.script}
        '';
      };
    };
}
