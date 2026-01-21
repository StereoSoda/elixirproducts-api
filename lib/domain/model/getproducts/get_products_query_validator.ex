defmodule ProductsApi.Domain.Model.GetProducts.GetProductsQueryValidator do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy

  @filters_allowed ["tipo", "nombre", "precio"]
  @types_allowed ["Tecnología", "Moda", "Alimento"]

  def validate!(any_filter, any_value, ctx) do
    f_blank = blank?(any_filter)
    v_blank = blank?(any_value)

    cond do
      f_blank and v_blank ->
        :ok

      f_blank or v_blank ->
        raise BusinessException.new(:er400, ctx, :invalid_query, "any_filter/any_value")

      true ->
        filter = ProductKeyPolicy.normalize(any_filter)

        if filter not in @filters_allowed do
          raise BusinessException.new(:er400, ctx, :invalid_filter, "any_filter")
        end

        case filter do
          "tipo" ->
            validate_type!(any_value, ctx)

          "nombre" ->
            validate_name!(any_value, ctx)

          "precio" ->
            validate_price!(any_value, ctx)
        end
    end
  end

  defp validate_type!(v, ctx) do
    if blank?(v), do: raise(BusinessException.new(:er400, ctx, :type_required, "any_value"))

    norm = ProductKeyPolicy.normalize(v)

    ok =
      Enum.any?(@types_allowed, fn t ->
        ProductKeyPolicy.normalize(t) == norm
      end)

    if not ok, do: raise(BusinessException.new(:er400, ctx, :invalid_type, "any_value"))
    :ok
  end

  defp validate_name!(v, ctx) do
    if blank?(v), do: raise(BusinessException.new(:er400, ctx, :name_required, "any_value"))
    :ok
  end

  # price viene como STRING. Debe ser entero/decimal > 0.
  defp validate_price!(v, ctx) do
    if blank?(v), do: raise(BusinessException.new(:er400, ctx, :price_required, "any_value"))

    s = String.trim(to_string(v))

    case Float.parse(s) do
      {n, ""} when n > 0 -> :ok
      _ -> raise(BusinessException.new(:er400, ctx, :invalid_price, "any_value"))
    end
  end

  defp blank?(nil), do: true
  defp blank?(v) when is_binary(v), do: String.trim(v) == ""
  defp blank?(v), do: String.trim(to_string(v)) == ""
end
