defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.AddProductsRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.Product

  OpenApiSpex.schema(%{
    title: "AddProductsRequest",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          products: %Schema{
            type: :array,
            items: Product
          }
        },
        required: [:products]
      }
    },
    required: [:data]
  })
end
