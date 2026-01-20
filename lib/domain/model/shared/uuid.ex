defmodule ProductsApi.Domain.Model.Shared.UUID do
  @moduledoc false

  def new(), do: UUID.uuid4()

  def valid?(value) when is_binary(value) do
    case UUID.info(value) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def valid?(_), do: false
end
