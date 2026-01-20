defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.ResponseBuilder do
  @moduledoc false

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.DateTimeProvider

  def success_add_products(message_id) do
    %{
      "meta" => %{
        "creationDate" => DateTimeProvider.now_formatted(),
        "message-id" => message_id
      },
      "data" => %{
        "message" => "Los productos fueron guardados exitosamente"
      }
    }
  end

  def error(message_id, code, message) do
    %{
      "meta" => %{
        "executionDate" => DateTimeProvider.now_formatted(),
        "message-id" => message_id
      },
      "error" => %{
        "code" => code,
        "message" => message
      }
    }
  end
end
