defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.AddProducts.AddProductsMapper do
  alias ProductsApi.Domain.Model.AddProducts.Model.Product
  alias ProductsApi.Domain.Model.AddProducts.Model.AddProductsPayload

  def to_payload(%{"data" => %{"products" => products}}) when is_list(products) do
    list =
      Enum.map(products, fn p ->
        %Product{
          name: p["name"],
          type: p["type"],
          quantity: p["quantity"],
          price: p["price"],
          currency: p["currency"]
        }
      end)

    %AddProductsPayload{products: list}
  end

  def to_payload(_), do: nil
end
