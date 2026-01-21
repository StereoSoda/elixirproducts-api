defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.GetProducts.GetProductsMapper do
  @moduledoc false

  def to_response_products(products) when is_list(products) do
    Enum.map(products, fn p ->
      %{
        "name" => to_s(p.name),
        "type" => to_s(p.type),
        "quantity" => to_s(p.quantity),
        "price" => to_s(p.price),
        "currency" => to_s(p.currency)
      }
    end)
  end

  defp to_s(nil), do: ""
  defp to_s(v) when is_binary(v), do: String.trim(v)
  defp to_s(v), do: v |> to_string() |> String.trim()
end
