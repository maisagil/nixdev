{ pkgs, config, lib, ... }:
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
      pkgs.cargo-watch
      pkgs.sqlx-cli
      pkgs.cargo-nextest
    ];

    # Languages
    languages.rust = {
      enable = true;
      channel = "nightly";
      rustflags = "-Z threads=8";
    };
    languages.nix.enable = true;

    scripts.run_tests.exec = "cargo watch -x 'nextest run'";

    pre-commit.hooks = {
      rustfmt = {
        enable = true;
        files = "\.rs$";
      };
    };
  };
}
