defmodule ProductsApi.Application.Ports.GetProducts.ProductQueryPort do
  @moduledoc false

  @callback list_all() :: {:ok, list()} | {:error, term()}
end
