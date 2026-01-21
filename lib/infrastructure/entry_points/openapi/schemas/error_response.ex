defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.ErrorResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ErrorResponse",
    type: :object,
    properties: %{
      meta: %Schema{
        type: :object,
        properties: %{
          executionDate: %Schema{type: :string},
          messageId: %Schema{type: :string, format: :uuid}
        }
      },
      error: %Schema{
        type: :object,
        properties: %{
          code: %Schema{type: :string},
          message: %Schema{type: :string},
          details: %Schema{type: :array, items: %Schema{type: :string}}
        }
      }
    },
    required: [:meta, :error]
  })
end
