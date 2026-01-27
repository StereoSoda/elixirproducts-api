import Config

config :products_api,
  timezone: "America/Bogota",
  env: :dev,
  http_port: 8083,
  enable_server: true,
  version: "0.0.1",
  custom_metrics_prefix_name: "products_api_local"

config :logger,
  level: :debug
