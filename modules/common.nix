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
    custom.common = {
      project_name = lib.mkOption {
        type = lib.types.str;
        default = "nameless";
        description = "Name of the project";
      };
      environment = lib.mkOption {
        type = lib.types.str;
        default = "local";
        example = "staging";
        description = "Application environment.";
      };
    };
  };
  config =
    {
      # Environment variables for all services.
      env.APP_ENVIRONMENT = lib.mkDefault cfg.common.environment;
      env.NODE_ENV = lib.mkDefault cfg.common.environment;

      # https://devenv.sh/packages/
      packages = [
        pkgs.lazygit
        pkgs.openssl
      ];

      enterShell =
        let
          text = ''
            Devshell initilized for ${cfg.common.project_name}...
            Welcome to the ${cfg.common.project_name} development environment.
            Crafted by eloback(2024-05-13).
          '';
        in
        ''
          echo "${text}"
          ${if cfg.sops.enable then "sops_populate_config" else ""}
        '';
    };
}
