defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.ErrorMapper do
  def status(:er400), do: 400
  def status(:er409), do: 409
  def status(:er500), do: 500
  def status(_), do: 500
end
