defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductRepositoryAdapter do
  @behaviour ProductsApi.Application.Ports.AddProducts.ProductRepositoryPort

  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.ProductIdGenerator
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.AddProducts.Model.Product

  def exists_by_key(key), do: EtsStore.exists?(key)

  def save_all(products) when is_list(products) do
    try do
      Enum.each(products, fn p ->
        key = ProductKeyPolicy.build_key(p)
        id = ProductIdGenerator.next_id()
        EtsStore.put(key, Product.with_id(p, id))
      end)

      :ok
    rescue
      _ -> {:error, :store_error}
    end
  end
end
