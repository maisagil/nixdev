{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom;
in
{
  options = {
    custom.rust = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the module";
      };
    };
  };
  config = lib.mkIf cfg.rust.enable {
    packages = [
      pkgs.sqlx-cli
      pkgs.cargo-nextest
    ];

    # Languages
    languages.rust = lib.mkDefault {
      enable = true;
      channel = "nightly";
      rustflags = "-Z threads=8";
    };

    scripts.run_tests.exec = "cargo watch -x 'nextest run'";

    git-hooks.hooks = {
      rustfmt = {
        enable = true;
        files = "\.rs$";
      };
      clippy = {
        enable = true;
        settings = {
          denyWarnings = true;
          allFeatures = true;
        };
      };
    };
  };
}
