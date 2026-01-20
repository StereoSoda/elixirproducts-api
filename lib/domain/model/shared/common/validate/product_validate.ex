defmodule ProductsApi.Domain.Model.Shared.Common.Validate.ProductValidate do
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  @types_allowed ["tecnologia", "moda", "alimento"]
  @currencies_allowed ["cop"]

  def validate!(%{name: name, type: type, currency: c, quantity: q, price: price}, ctx) do
    cond do
      blank?(name) -> raise BusinessException.new(:er400, ctx)
      blank?(type) -> raise BusinessException.new(:er400, ctx)
      blank?(c) -> raise BusinessException.new(:er400, ctx)
      not (normalize(type) in @types_allowed) -> raise BusinessException.new(:er400, ctx)
      not (normalize(c) in @currencies_allowed) -> raise BusinessException.new(:er400, ctx)
      not positive_int_string?(q) -> raise BusinessException.new(:er400, ctx)
      not positive_number_string?(price) -> raise BusinessException.new(:er400, ctx)
      true -> :ok
    end
  end

  defp positive_int_string?(s) when is_binary(s) do
    t = String.trim(s)
    Regex.match?(~r/^\d+$/, t) and String.to_integer(t) > 0
  rescue
    _ -> false
  end
  defp positive_int_string?(_), do: false

  defp positive_number_string?(s) when is_binary(s) do
    t = String.trim(s)

    # Si el reto permite solo enteros: usa /^\d+$/
    Regex.match?(~r/^\d+$/, t) and String.to_integer(t) > 0
  rescue
    _ -> false
  end
  defp positive_number_string?(_), do: false

  defp blank?(v), do: v == nil or (is_binary(v) and String.trim(v) == "")

  defp normalize(v) do
    v
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/\s+/, " ")
  end
end
