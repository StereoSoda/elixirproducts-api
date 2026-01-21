defmodule ProductsApi.Domain.UseCase.GetProducts.GetProductsUseCase do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Cqrs.{Query, ContextData}
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.GetProducts.GetProductsQueryValidator

  @spec execute(Query.t(), module()) :: list() | no_return()
  def execute(%Query{params: params, context: %ContextData{} = ctx}, repo_mod) do
    any_filter = Map.get(params, "any_filter")
    any_value = Map.get(params, "any_value")

    GetProductsQueryValidator.validate!(any_filter, any_value, ctx)

    products =
      case repo_mod.list_all() do
        {:ok, list} when is_list(list) -> list
        {:error, _} -> raise BusinessException.new(:er500, ctx, :store_error, "products")
      end

    filtered = apply_filter(products, any_filter, any_value)

    if filtered == [] do
      raise BusinessException.new(:er409, ctx, :no_products_found, "products")
    end

    filtered
  end

  defp apply_filter(products, any_filter, any_value) do
    if is_blank?(any_filter) and is_blank?(any_value) do
      products
    else
      filter = ProductKeyPolicy.normalize(any_filter)
      value = ProductKeyPolicy.normalize(any_value)

      Enum.filter(products, fn p ->
        case filter do
          "tipo" ->
            ProductKeyPolicy.normalize(p.type) == value

          "nombre" ->
            ProductKeyPolicy.normalize(p.name) == value

          "precio" ->
            ProductKeyPolicy.normalize(to_string(p.price)) == value

          _ ->
            false
        end
      end)
    end
  end

  defp is_blank?(nil), do: true
  defp is_blank?(v) when is_binary(v), do: String.trim(v) == ""
  defp is_blank?(v), do: String.trim(to_string(v)) == ""
end
