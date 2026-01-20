defmodule Products.Shared.Common.Model.ProductKey do
  def build_key(%{name: name, type: type, currency: currency}) do
    [
      norm(name),
      norm(type),
      norm(currency)
    ]
    |> Enum.join("|")
  end

  defp norm(v) when is_binary(v),
    do: v |> String.trim() |> String.downcase()

  defp norm(v),
    do: v |> to_string() |> String.trim() |> String.downcase()
end
