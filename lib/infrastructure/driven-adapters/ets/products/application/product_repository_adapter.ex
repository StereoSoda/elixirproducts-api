defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Application.ProductRepositoryAdapter do
  @behaviour ProductsApi.Application.Ports.AddProducts.ProductRepositoryPort

  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.ProductIdGenerator
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.AddProducts.Model.Product

  @impl true
  def exists_by_key(key) when is_binary(key), do: EtsStore.exists?(key)

  @impl true
  def save_all(products) when is_list(products) do
    try do
      Enum.each(products, fn %Product{} = p ->
        key = ProductKeyPolicy.build_key(p)
        id = ProductIdGenerator.next_id()
        EtsStore.put(key, Product.with_id(p, id))
      end)

      :ok
    rescue
      e ->
        # opcional: Logger.error(Exception.format(:error, e, __STACKTRACE__))
        {:error, {:store_error, e}}
    end
  end
end
