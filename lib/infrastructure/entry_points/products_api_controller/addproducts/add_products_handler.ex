defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsHandler do
  import Plug.Conn

  alias ProductsApi.Domain.Model.Shared.Cqrs.Command
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.{
    HeaderContextExtractor,
    ErrorMapper,
    ResponseBuilder,
    DateTimeProvider
  }

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsMapper
  alias ProductsApi.Domain.UseCase.AddProducts.AddProductsUseCase
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductRepositoryAdapter

  @success_msg "Los productos fueron guardados exitosamente"
  @internal_msg "Hay un error interno en el sistema"
  @bad_msg "Hay un error técnico, revisar datos ingresados"
  @conflict_msg "Uno de los productos ingresados ya existe en el sistema"

  def handle(conn) do
    # Extrae el contexto para respetar IDs incluso en errores desconocidos
    ctx = HeaderContextExtractor.extract_or_throw(conn)

    try do
      payload = AddProductsMapper.to_payload(conn.body_params)

      cmd = %Command{payload: payload, context: ctx}
      :ok = AddProductsUseCase.execute(cmd, ProductRepositoryAdapter)

      body =
        ResponseBuilder.success(
          ctx.message_id,
          DateTimeProvider.now_formatted(),
          @success_msg
        )

      conn
      |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx.x_request_id)
      |> put_resp_content_type("application/json")
      |> send_resp(201, Jason.encode!(body))
    rescue
      e in [BusinessException] ->
        # Desestructura la excepción aquí (válido)
        %BusinessException{code: code, context: ctx2} = e

        status = ErrorMapper.status(code)

        msg =
          case code do
            :er400 -> @bad_msg
            :er409 -> @conflict_msg
            _ -> @internal_msg
          end

        body =
          ResponseBuilder.error(
            ctx2.message_id,
            DateTimeProvider.now_formatted(),
            code |> Atom.to_string() |> String.upcase(),
            msg
          )

        conn
        |> put_resp_header(HeaderContextExtractor.x_request_id_header(), ctx2.x_request_id)
        |> put_resp_content_type("application/json")
        |> send_resp(status, Jason.encode!(body))

      _e ->
        # Error desconocido: respeta IDs del request (reto)
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
