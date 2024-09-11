{ lib, config, ... }:
let
  cfg = config.custom;
  project_name = config.project_name;
  db_name = project_name;
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
        initialDatabases = [{ name = db_name; }];
        initdbArgs = [ "--locale=C" "--encoding=UTF8" "--username=${db_user}" ];
      };
    };
    env = {
      DATABASE_URL = lib.mkDefault "postgres://${config.env.PGUSER}:${config.env.PGPASSWORD}@${lib.escapeURL config.env.DEVENV_RUNTIME}%2fpostgres";
      "DB_UI_${project_name}_local" = config.env.DATABASE_URL;
      PGUSER = db_user;
      PGPASSWORD = db_pass;
      PGDATABASE = db_name;
    };
  };
}
