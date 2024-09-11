{ lib, config, ... }: {
  options = {
    enable_otel = lib.mkEnableOption "Enable this module";
    enable_collector = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OTEL collector.";
    };
    enable_clickhouse = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable clickhouse service.";
    };
  };
  config = lib.mkIf config.enable_otel {
    # Enable exponential histograms.
    env.OTEL_EXPORTER_OTLP_METRICS_DEFAULT_HISTOGRAM_AGGREGATION = "BASE2_EXPONENTIAL_BUCKET_HISTOGRAM";

    # Prefer delta temporality.
    env.OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE = "DELTA";

    # Maximum allowed time to export data in milliseconds.
    env.OTEL_BSP_EXPORT_TIMEOUT = 10000;

    # Maximum batch size.
    # Using larger batch sizes can be problematic,
    # because Uptrace rejects requests larger than 20MB.
    env.OTEL_BSP_MAX_EXPORT_BATCH_SIZE = 10000;

    # Maximum queue size.
    # Increase queue size if you have lots of RAM, for example,
    # `10000 * number_of_gigabytes`.
    env.OTEL_BSP_MAX_QUEUE_SIZE = 30000;

    # Max concurrent exports.
    # Setting this to the number of available CPUs might be a good idea.
    env.OTEL_BSP_MAX_CONCURRENT_EXPORTS = 2;

    # Enable gzip compression.
    # Server don't support apparently
    env.OTEL_EXPORTER_OTLP_COMPRESSION = "gzip";

    env.DB_UI_CLICKHOUSE_LOCAL = "clickhouse://localhost/otel";

    services = {
      clickhouse = lib.mkIf config.enable_collector {
        enable = true;
        config = ''
          users:
            default:
              access_management: 1
              named_collection_control: 1
              show_named_collections: 1
              show_named_collections_secrets: 1
            eloback:
              access_management: 1
              named_collection_control: 1
              show_named_collections: 1
              show_named_collections_secrets: 1
              networks:
                ip: ::/0
              password: "123123"
        '';
      };
      opentelemetry-collector = lib.mkIf config.enable_clickhouse {
        enable = true;
        settings = {
          receivers = {
            otlp = {
              protocols = {
                grpc = { };
                http = { };
              };
            };
          };

          processors = {
            batch = {
              timeout = "10s";
              send_batch_size = 100000;
            };
            cumulativetodelta = { };
          };

          extensions = {
            zpages = {
              endpoint = "localhost:55679";
            };
          };
          service = {
            extensions = [
              "zpages"
            ];
          };

          exporters = {
            debug = {
              verbosity = "detailed";
            };
            clickhouse = {
              endpoint = "tcp://127.0.0.1:9000?dial_timeout=10s&compress=lz4";
              database = "otel";
              ttl_days = 3;
              logs_table_name = "otel_logs";
              traces_table_name = "otel_traces";
              metrics_table_name = "otel_metrics";
              timeout = "5s";
              retry_on_failure = {
                enabled = true;
                initial_interval = "5s";
                max_interval = "30s";
                max_elapsed_time = "300s";
              };
            };
          };

          service = {
            pipelines = {
              traces = {
                receivers = [ "otlp" ];
                processors = [ "batch" ];
                exporters = [ "clickhouse" "debug" ];
              };
              metrics = {
                receivers = [ "otlp" ];
                processors = [ "batch" "cumulativetodelta" ];
                exporters = [ "clickhouse" "debug" ];
              };
              logs = {
                receivers = [ "otlp" ];
                processors = [ "batch" ];
                exporters = [ "clickhouse" "debug" ];
              };
            };
          };
        };
      };
    };
    processes.opentelemetry-collector = lib.mkIf config.enable_clickhouse {
      process-compose.depends_on.clickhouse-server.condition = "process_healthy";
    };
  };
}
