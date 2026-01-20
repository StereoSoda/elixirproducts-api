defmodule ProductsApi.Application.Ports.AddProducts.ProductRepositoryPort do
  @callback exists_by_key(String.t()) :: boolean()
  @callback save_all([map()]) :: :ok | {:error, term()}
end
