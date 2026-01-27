import Config

config :products_api,
  timezone: "America/Bogota",
  env: :test,
  http_port: 8083,
  enable_server: true,
  version: "0.0.1",
  custom_metrics_prefix_name: "products_api_test"

config :logger,
  level: :info

config :junit_formatter,
  report_dir: "_build/release",
  automatic_create_dir?: true,
  report_file: "test-junit-report.xml"

config :elixir_structure_manager,
  sonar_base_folder: ""
