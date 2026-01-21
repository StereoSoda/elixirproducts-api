defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.AddProductsResponse201 do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "AddProductsResponse201",
    type: :object,
    properties: %{
      meta: %Schema{
        type: :object,
        properties: %{
          messageId: %Schema{type: :string, format: :uuid}
        },
        required: [:messageId]
      },
      data: %Schema{
        type: :object,
        properties: %{
          message: %Schema{type: :string}
        },
        required: [:message]
      }
    },
    required: [:meta, :data]
  })
end
