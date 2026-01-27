import Config

config :products_api,
  timezone: "America/Bogota",
  env: :prod,
  http_port: 8083,
  enable_server: true,
  version: "0.0.1",
  custom_metrics_prefix_name: "products_api"

config :logger,
  level: :warning
