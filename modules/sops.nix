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
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the module";
      };
      env_as_config_path = lib.mkOption {
        type = lib.types.str;
        default = ".";
        description = "Path to store the unencrypted environment secrets";
      };
      env_as_config_script = lib.mkOption {
        type = lib.types.str;
        default = "${pkgs.sops}/bin/sops -d ${cfg.common.environment}.secrets.yaml > ${cfg.sops.env_as_config_path}/unencrypted_${cfg.common.environment}_secrets.yaml";
        description = "Script to populate environment secrets";
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
          ${cfg.sops.env_as_config_script}
        '';
      };
    };
}
