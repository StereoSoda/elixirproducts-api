defmodule ProductsApi.Domain.UseCase.AddProducts.AddProductsUseCase do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Cqrs.{Command, ContextData}
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  alias ProductsApi.Domain.Model.AddProducts.Model.{AddProductsPayload, Product}
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.Shared.Common.Validate.ProductValidate

  @spec execute(Command.t(), module()) :: :ok | no_return()
  def execute(%Command{payload: payload, context: %ContextData{} = ctx}, repo_mod) do
    products = extract_products!(payload, ctx)

    Enum.each(products, &ProductValidate.validate!(&1, ctx))

    keys = Enum.map(products, &ProductKeyPolicy.build_key/1)

    if has_duplicates?(keys) do
      raise(BusinessException.new(:er400, ctx, :duplicate_in_request, "products"))
    end

    if Enum.any?(keys, fn key -> repo_mod.exists_by_key(key) end) do
      raise(BusinessException.new(:er409, ctx, :already_exists, "products"))
    end

    case repo_mod.save_all(products) do
      :ok -> :ok
      {:error, _} -> raise(BusinessException.new(:er500, ctx, :store_error, "products"))
    end
  end

  defp extract_products!(%AddProductsPayload{products: products}, ctx) when is_list(products) do
    cond do
      products == [] ->
        raise(BusinessException.new(:er400, ctx, :missing_products, "products"))

      Enum.any?(products, &(&1 == :invalid_product_item)) ->
        raise(BusinessException.new(:er400, ctx, :invalid_products, "products"))

      not Enum.all?(products, fn p -> match?(%Product{}, p) end) ->
        raise(BusinessException.new(:er400, ctx, :invalid_products, "products"))

      true ->
        products
    end
  end

  defp extract_products!(nil, ctx) do
    raise(BusinessException.new(:er400, ctx, :missing_products, "products"))
  end

  defp extract_products!(_other, ctx) do
    raise(BusinessException.new(:er400, ctx, :missing_products, "products"))
  end

  defp has_duplicates?(list) do
    list
    |> Enum.frequencies()
    |> Enum.any?(fn {_k, count} -> count > 1 end)
  end
end
