defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.ResponseBuilder do
  @moduledoc false

  def success(message_id, creation_date, msg) do
    %{
      "meta" => %{
        "creationDate" => creation_date,
        "message-id" => message_id
      },
      "data" => %{
        "message" => msg
      }
    }
  end

  def error(message_id, execution_date, code, msg) do
    %{
      "meta" => %{
        "executionDate" => execution_date,
        "message-id" => message_id
      },
      "error" => %{
        "code" => code,
        "message" => msg
      }
    }
  end
end
