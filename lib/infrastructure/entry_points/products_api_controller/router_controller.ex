defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController do
  use Plug.Router
  import Plug.Conn

  alias ProductsApi.Infrastructure.EntryPoints.OpenApi.ApiSpec
  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsHandler
  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.GetProducts.GetProductsHandler

  plug(Plug.Logger, log: :info)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json],
    json_decoder: Jason
  )

  # Esto registra el spec en el conn para que RenderSpec funcione
  plug(OpenApiSpex.Plug.PutApiSpec, module: ApiSpec)

  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "")
  end

  # OpenAPI JSON
  get "/openapi" do
    OpenApiSpex.Plug.RenderSpec.call(conn, [])
  end

  # Swagger UI
  get "/swaggerui" do
    opts = OpenApiSpex.Plug.SwaggerUI.init(path: "/openapi")
    OpenApiSpex.Plug.SwaggerUI.call(conn, opts)
  end

  post "/addProducts" do
    AddProductsHandler.handle(conn)
  end

  get "/getProducts" do
    GetProductsHandler.handle(conn)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
