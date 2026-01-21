defmodule ProductsApi.Domain.Model.Shared.Common.Validate.ProductValidate do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.AddProducts.Model.Product

  @types_allowed ["Tecnología", "Moda", "Alimento"]
  @currencies_allowed ["COP", "USD", "EUR"]

  @spec validate!(Product.t(), any()) :: :ok | no_return()
  def validate!(%Product{} = p, ctx) do
    name = p.name
    type = p.type
    currency = p.currency
    quantity = p.quantity
    price = p.price

    cond do
      blank?(name) ->
        raise BusinessException.new(:er400, ctx, :name_required, "name")

      blank?(type) ->
        raise BusinessException.new(:er400, ctx, :type_required, "type")

      blank?(currency) ->
        raise BusinessException.new(:er400, ctx, :currency_required, "currency")

      not valid_type?(type) ->
        raise BusinessException.new(:er400, ctx, :invalid_type, "type")

      not valid_currency?(currency) ->
        raise BusinessException.new(:er400, ctx, :invalid_currency, "currency")

      not integer_positive?(quantity) ->
        raise BusinessException.new(:er400, ctx, :invalid_quantity, "quantity")

      not number_positive?(price) ->
        raise BusinessException.new(:er400, ctx, :invalid_price, "price")

      true ->
        :ok
    end
  end

  # ----------------
  # Allowed values
  # ----------------

  defp valid_type?(t) do
    Enum.any?(@types_allowed, fn allowed ->
      ProductKeyPolicy.normalize(allowed) == ProductKeyPolicy.normalize(t)
    end)
  end

  defp valid_currency?(c) do
    c
    |> str_or_empty()
    |> String.trim()
    |> String.upcase()
    |> then(&Enum.member?(@currencies_allowed, &1))
  end

  # ----------------
  # Numeric rules (strings)
  # ----------------

  # quantity debe ser entero positivo (string "1", "2", ...)
  defp integer_positive?(v) when is_integer(v), do: v > 0

  defp integer_positive?(v) when is_binary(v) do
    t = String.trim(v)

    case Integer.parse(t) do
      {n, ""} when n > 0 -> true
      _ -> false
    end
  end

  defp integer_positive?(_), do: false

  # price: si el reto lo quiere como entero, esto está perfecto.
  # Si lo quisieras decimal, te dejo variante abajo.
  defp number_positive?(v) when is_integer(v), do: v > 0
  defp number_positive?(v) when is_float(v), do: v > 0

  defp number_positive?(v) when is_binary(v) do
    t = String.trim(v)

    case Integer.parse(t) do
      {n, ""} when n > 0 -> true
      _ -> false
    end
  end

  defp number_positive?(_), do: false

  # ----------------
  # Helpers
  # ----------------

  defp blank?(v), do: is_nil(v) or (is_binary(v) and String.trim(v) == "")

  defp str_or_empty(nil), do: ""
  defp str_or_empty(v) when is_binary(v), do: v
  defp str_or_empty(v), do: to_string(v)
end
