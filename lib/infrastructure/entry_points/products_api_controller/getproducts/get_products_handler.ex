defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.GetProducts.GetProductsHandler do
  import Plug.Conn

  alias ProductsApi.Domain.Model.Shared.Cqrs.Query
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.{
    HeaderContextExtractor,
    ErrorMapper,
    ResponseBuilder,
    DateTimeProvider
  }

  alias ProductsApi.Domain.UseCase.GetProducts.GetProductsUseCase
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductQueryAdapter
  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.GetProducts.GetProductsMapper

  @internal_msg "Hay un error interno en el sistema"
  @bad_msg "Hay un error técnico, revisar datos ingresados"
  @conflict_msg "No se encontraron productos"

  def handle(conn) do
    ctx = HeaderContextExtractor.extract_or_throw(conn)

    try do
      params = conn.params || %{}

      query = %Query{params: params, context: ctx}
      products = GetProductsUseCase.execute(query, ProductQueryAdapter)

      body = %{
        "meta" => %{
          "executionDate" => DateTimeProvider.now_formatted(),
          "message-id" => ctx.message_id
        },
        "data" => %{
          "products" => GetProductsMapper.to_response_products(products)
        }
      }

      conn
      |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx.x_request_id)
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(body))
    rescue
      e in [BusinessException] ->
        status = ErrorMapper.status(e.code)

        msg =
          case e.code do
            :er400 -> @bad_msg
            :er409 -> @conflict_msg
            _ -> @internal_msg
          end

        body =
          ResponseBuilder.error(
            e.context.message_id,
            DateTimeProvider.now_formatted(),
            e.code |> Atom.to_string() |> String.upcase(),
            msg
          )

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), e.context.x_request_id)
        |> put_resp_content_type("application/json")
        |> send_resp(status, Jason.encode!(body))

      _ ->
        body =
          ResponseBuilder.error(
            ctx.message_id,
            DateTimeProvider.now_formatted(),
            "ER500",
            @internal_msg
          )

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx.x_request_id)
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(body))
    end
  end
end
