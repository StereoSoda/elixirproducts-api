defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController do
  use Plug.Router

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsHandler
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore

  plug(Plug.Logger, log: :info)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  )

  plug(:dispatch)

  post "/addProducts" do
    # asegura ETS listo
    :ok = EtsStore.init!()
    AddProductsHandler.handle(conn)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
