defmodule ProductsApi.Application do
  @moduledoc false
  use Application

  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStoreOwner
  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController

  @impl true
  def start(_type, _args) do
    port = http_port()

    children = [
      # 1) ETS owner (crea y mantiene viva la tabla)
      {EtsStoreOwner, []},

      # 2) HTTP server
      {Plug.Cowboy, scheme: :http, plug: RouterController, options: [port: port]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ProductsApi.Supervisor)
  end

  defp http_port do
    case System.get_env("PORT") do
      nil ->
        4000

      p ->
        case Integer.parse(p) do
          {port, ""} -> port
          _ -> 4000
        end
    end
  end
end
