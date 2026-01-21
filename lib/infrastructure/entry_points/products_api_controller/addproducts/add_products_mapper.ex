defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsMapper do
  @moduledoc false

  alias ProductsApi.Domain.Model.AddProducts.Model.{Product, AddProductsPayload}

  def to_payload(%{"data" => %{"products" => products}}) when is_list(products) do
    list =
      Enum.map(products, fn
        %{} = p ->
          %Product{
            name: str_or_nil(Map.get(p, "name")),
            type: str_or_nil(Map.get(p, "type")),
            quantity: str_or_nil(Map.get(p, "quantity")),
            price: str_or_nil(Map.get(p, "price")),
            currency: str_or_nil(Map.get(p, "currency"))
          }

        _other ->
          # Dejamos un marcador inválido para que el usecase dispare ER400 con reason invalid_products
          :invalid_product_item
      end)

    %AddProductsPayload{products: list}
  end

  def to_payload(_), do: nil

  defp str_or_nil(nil), do: nil
  defp str_or_nil(v) when is_binary(v), do: String.trim(v)
  defp str_or_nil(v), do: v |> to_string() |> String.trim()
end
