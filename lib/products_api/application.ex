defmodule ProductsApi.Application do
  @moduledoc false
  use Application

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController

  @impl true
  def start(_type, _args) do
    port = http_port()

    children = [
      # HTTP server
      {Plug.Cowboy, scheme: :http, plug: RouterController, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: ProductsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_port do
    case System.get_env("PORT") do
      nil -> 4000
      p -> String.to_integer(p)
    end
  end
end
