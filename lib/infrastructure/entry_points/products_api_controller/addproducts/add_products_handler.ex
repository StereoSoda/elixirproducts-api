defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsHandler do
  import Plug.Conn

  alias ProductsApi.Domain.Model.Shared.Cqrs.Command
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.{
    HeaderContextExtractor,
    ErrorMapper,
    ResponseBuilder
  }

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsMapper
  alias ProductsApi.Domain.UseCase.AddProducts.AddProductsUseCase
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductRepositoryAdapter

  def handle(conn) do
    try do
      ctx = HeaderContextExtractor.extract_or_throw(conn)
      payload = AddProductsMapper.to_payload(conn.body_params)

      cmd = %Command{payload: payload, context: ctx}
      :ok = AddProductsUseCase.execute(cmd, ProductRepositoryAdapter)

      body = ResponseBuilder.success_add_products(ctx.message_id)

      conn
      |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx.x_request_id)
      |> put_resp_content_type("application/json")
      |> send_resp(201, Jason.encode!(body))
    rescue
      e in BusinessException ->
        code = e.code
        ctx2 = e.context

        status = ErrorMapper.status(code)
        body = ResponseBuilder.error(ctx2.message_id, ErrorMapper.code_str(code), ErrorMapper.message(code))

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx2.x_request_id)
        |> put_resp_content_type("application/json")
        |> send_resp(status, Jason.encode!(body))

      _ ->
        # Si algo no controlado revienta, pero igual devolvemos ER500 con IDs del request si existen.
        # Si por alguna razón no existen, generamos.
        xrid = get_req_header(conn, HeaderContextExtractor.x_request_id_header()) |> List.first() || UUID.uuid4()
        mid = get_req_header(conn, "message-id") |> List.first() || UUID.uuid4()

        body = ResponseBuilder.error(mid, "ER500", "Hay un error interno en el sistema")

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), xrid)
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(body))
    end
  end
end
