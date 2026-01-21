defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.HeaderContextExtractor do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Cqrs.ContextData
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  @message_id "message-id"
  @x_request_id "x-request-id"

  def message_id_header, do: @message_id
  def x_request_id_header, do: @x_request_id

  def extract_or_throw(conn) do
    mid = get_req_header(conn, @message_id)
    rid = get_req_header(conn, @x_request_id)

    cond do
      not valid_uuid?(mid) and not valid_uuid?(rid) ->
        ctx = new_error_ctx()
        raise(BusinessException.new(:er400, ctx, :invalid_headers, "#{@message_id},#{@x_request_id}"))

      not valid_uuid?(mid) ->
        ctx = new_error_ctx()
        raise(BusinessException.new(:er400, ctx, :invalid_header, @message_id))

      not valid_uuid?(rid) ->
        ctx = new_error_ctx()
        raise(BusinessException.new(:er400, ctx, :invalid_header, @x_request_id))

      true ->
        %ContextData{message_id: mid, x_request_id: rid}
    end
  end

  defp get_req_header(conn, key) do
    conn
    |> Plug.Conn.get_req_header(key)
    |> List.first()
  end

  defp valid_uuid?(nil), do: false

  defp valid_uuid?(v) when is_binary(v) do
    case UUID.info(v) do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp new_error_ctx do
    %ContextData{message_id: UUID.uuid4(), x_request_id: UUID.uuid4()}
  end
end
