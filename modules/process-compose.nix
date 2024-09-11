# NOTE: add this to your `devenv.yaml` to enable unstable features.
# nixpkgs-unstable:
#   url: github:NixOS/nixpkgs/nixos-unstable
{ pkgs, inputs, lib, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{
  process-managers.process-compose = {
    # NOTE: fix so that the "ready_log_line" feature works.
    package = pkgs-unstable.process-compose;
    settings = {
      fields_order = [ "time" "process" "level" "message" ];
      log_location = ".devenv/process-compose.log";
      log_configuration = {
        disable_json = false;
        add_timestamp = true;
        flush_each_line = true;
        rotation = {
          max_size_mb = 1; # the max size in MB of the logfile before it's rolled
          max_age_days = 3; # the max age in days to keep a logfile
          max_backups = 2; # the max number of rolled files to keep
          compress = true; # determines if the rotated log files should be compressed using gzip. The default is false
        };
      };
    };
  };
  scripts."show_logs".exec = "${lib.getExe pkgs.tailspin} -f .devenv/process-compose.log";
  # call devenv processes down after terminating the logs
  scripts."pup".exec = ''
    down_processes() {
      echo "Downing processes... 🔥"
      devenv processes down
      echo "Processes downed. 🛑"
    }
    int_handler()
    {
        down_processes
        exit 1
    }
    trap 'int_handler' INT
    echo "Starting processes... 🚀"
    devenv processes up -d && show_logs 
    down_processes
    exit 0
  '';
}
