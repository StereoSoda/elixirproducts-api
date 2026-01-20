defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.ResponseBuilder do
  def ok(meta, data), do: %{meta: meta, data: data}
  def error(meta, code, msg), do: %{meta: meta, error: %{code: code, message: msg, details: []}}
end
