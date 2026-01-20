defmodule ProductsApi.Domain.Model.AddProducts.Model.AddProductsPayload do
  @enforce_keys [:products]
  defstruct [:products]

  @type t :: %__MODULE__{products: [ProductsApi.Domain.Model.AddProducts.Model.Product.t()]}
end
