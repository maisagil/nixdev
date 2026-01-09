{
  ...
}:
{
  process.managers.process-compose = {
    settings = {
      log_location = ".devenv/process-compose.log";
      log_configuration = {
        disable_json = true;
        add_timestamp = true;
        flush_each_line = true;
        rotation = {
          max_size_mb = 1; # the max size in mb of the logfile before it's rolled
          max_age_days = 3; # the max age in days to keep a logfile
          max_backups = 2; # the max number of rolled files to keep
          compress = true; # determines if the rotated log files should be compressed using gzip. the default is false
        };

      };
    };
  };
  scripts."show_logs".exec = "tail -f .devenv/process-compose.log";
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
