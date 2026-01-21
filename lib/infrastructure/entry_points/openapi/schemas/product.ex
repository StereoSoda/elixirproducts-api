defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.Product do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Product",
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      type: %Schema{type: :string},
      quantity: %Schema{
        type: :string,
        description: "Cantidad (numérico representado como string)"
      },
      price: %Schema{
        type: :string,
        description: "Precio (numérico representado como string)"
      },
      currency: %Schema{type: :string}
    },
    required: [:name, :type, :quantity, :price, :currency]
  })
end
