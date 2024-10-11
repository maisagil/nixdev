{ lib, config, ... }:
let
  cfg = config.custom;
  db_user = "nixus";
  db_pass = "postgres";
in
{
  options.custom.pgdatabase = {
    enable = lib.mkEnableOption "Enable this module";
  };
  config = lib.mkIf cfg.pgdatabase.enable {
    services = {
      postgres = {
        enable = lib.mkDefault true;
        initialDatabases = [{ name = cfg.common.project_name; }];
        initdbArgs = [ "--locale=C" "--encoding=UTF8" "--username=${db_user}" ];
      };
    };
    env = {
      DATABASE_URL = lib.mkDefault "postgres://${config.env.PGUSER}:${config.env.PGPASSWORD}@${lib.escapeURL config.env.DEVENV_RUNTIME}%2fpostgres";
      DB_UI_POSTGRES_DEVENV = lib.mkDefault config.env.DATABASE_URL;
      PGUSER = lib.mkDefault db_user;
      PGPASSWORD = lib.mkDefault db_pass;
      PGDATABASE = lib.mkDefault cfg.common.project_name;
    };
  };
}
