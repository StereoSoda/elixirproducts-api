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

  @success_msg "Petición procesada exitosamente"
  @internal_msg "Hay un error interno en el sistema"
  @bad_msg "Solicitud inválida"
  @conflict_msg "El producto ya existe"

  def handle(conn) do
    try do
      ctx = HeaderContextExtractor.extract_or_throw(conn)
      payload = AddProductsMapper.to_payload(conn.body_params)

      cmd = %Command{payload: payload, context: ctx}
      :ok = AddProductsUseCase.execute(cmd, ProductRepositoryAdapter)

      conn
      |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx.x_request_id)
      |> put_resp_content_type("application/json")
      |> send_resp(
        201,
        Jason.encode!(%{meta: %{messageId: ctx.message_id}, data: %{message: @success_msg}})
      )
    rescue
      e in [BusinessException] ->
        code = e.code
        ctx2 = e.context

        status = ErrorMapper.status(code)

        msg =
          case code do
            :er400 -> @bad_msg
            :er409 -> @conflict_msg
            _ -> @internal_msg
          end

        body =
          ResponseBuilder.error(
            %{messageId: ctx2.message_id},
            code |> Atom.to_string() |> String.upcase(),
            msg
          )

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx2.x_request_id)
        |> put_resp_content_type("application/json")
        |> send_resp(status, Jason.encode!(body))

      _ ->
        xrid = UUID.uuid4()
        mid = UUID.uuid4()

        body = ResponseBuilder.error(%{messageId: mid}, "ER500", @internal_msg)

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), xrid)
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(body))
    end
  end
end
