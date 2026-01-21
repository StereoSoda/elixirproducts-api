defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.GetProductsResponse200 do
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.Product

  OpenApiSpex.schema(%{
    title: "GetProductsResponse200",
    type: :object,
    properties: %{
      meta: %Schema{
        type: :object,
        properties: %{
          executionDate: %Schema{type: :string},
          "message-id": %Schema{type: :string, format: :uuid}
        },
        required: [:executionDate, :"message-id"]
      },
      data: %Schema{
        type: :object,
        properties: %{
          products: %Schema{type: :array, items: Product}
        },
        required: [:products]
      }
    },
    required: [:meta, :data]
  })
end
