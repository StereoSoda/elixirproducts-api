defmodule Products.Shared.Common.Validate.UuidValidate do
  def valid?(value) when is_binary(value) do
    case UUID.info(value) do
      {:ok, _} -> true
      _ -> false
    end
  end

  def valid?(_), do: false
end
