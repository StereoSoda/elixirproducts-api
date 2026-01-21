defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductQueryAdapter do
  @behaviour ProductsApi.Application.Ports.GetProducts.ProductQueryPort

  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore

  @impl true
  def list_all() do
    try do
      {:ok, EtsStore.values()}
    rescue
      _ -> {:error, :store_error}
    end
  end
end
