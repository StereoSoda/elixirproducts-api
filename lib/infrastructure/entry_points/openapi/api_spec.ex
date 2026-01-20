defmodule ProductsApi.Infrastructure.EntryPoints.OpenApi.ApiSpec do
  @behaviour OpenApiSpex.OpenApi

  alias OpenApiSpex.{
    OpenApi,
    Info,
    Server,
    PathItem,
    Operation,
    RequestBody,
    Response,
    MediaType,
    Schema,
    Parameter
  }

  @impl OpenApiSpex.OpenApi
  def spec do
    %OpenApi{
      servers: [%Server{url: "/"}],
      info: %Info{
        title: "Products API",
        version: "1.0.0"
      },
      # En 3.22.x esto es un map normal con PathItems; NO uses Paths.from_paths/1
      paths: %{
        "/addProducts" => %PathItem{
          post: add_products_operation()
        },
        "/getProducts" => %PathItem{
          get: get_products_operation()
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end

  defp add_products_operation do
    %Operation{
      tags: ["Products"],
      summary: "Agregar productos",
      operationId: "addProducts",
      parameters: [
        header_param("message-id", "UUID del mensaje"),
        header_param("x-request-id", "UUID de correlación")
      ],
      requestBody: %RequestBody{
        required: true,
        content: %{
          "application/json" => %MediaType{
            schema: ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.AddProductsRequest
          }
        }
      },
      responses: %{
        201 => %Response{
          description: "Created",
          content: %{
            "application/json" => %MediaType{
              schema: ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.AddProductsResponse201
            }
          }
        },
        400 => error_response("Bad Request"),
        409 => error_response("Conflict"),
        500 => error_response("Internal Error")
      }
    }
  end

  defp get_products_operation do
    %Operation{
      tags: ["Products"],
      summary: "Listar productos",
      operationId: "getProducts",
      parameters: [
        header_param("message-id", "UUID del mensaje"),
        header_param("x-request-id", "UUID de correlación"),
        %Parameter{
          name: "any_filter",
          in: :query,
          required: false,
          schema: %Schema{type: :string},
          description: "Filtro permitido (tipo|nombre|precio)"
        },
        %Parameter{
          name: "any_value",
          in: :query,
          required: false,
          schema: %Schema{type: :string},
          description: "Valor del filtro"
        }
      ],
      responses: %{
        200 => %Response{
          description: "OK",
          content: %{
            "application/json" => %MediaType{
              schema: ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.GetProductsResponse200
            }
          }
        },
        400 => error_response("Bad Request"),
        409 => error_response("Conflict"),
        500 => error_response("Internal Error")
      }
    }
  end

  defp header_param(name, desc) do
    %Parameter{
      name: name,
      in: :header,
      required: true,
      schema: %Schema{type: :string, format: :uuid},
      description: desc
    }
  end

  defp error_response(desc) do
    %Response{
      description: desc,
      content: %{
        "application/json" => %MediaType{
          schema: ProductsApi.Infrastructure.EntryPoints.OpenApi.Schemas.ErrorResponse
        }
      }
    }
  end
end
