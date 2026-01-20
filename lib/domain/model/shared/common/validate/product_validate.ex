defmodule ProductsApi.Domain.Model.Shared.Common.Validate.ProductValidate do
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  @types_allowed ["Tecnología", "Moda", "Alimento"]
  @currencies_allowed ["COP"]

  def validate!(%{name: name, type: type, currency: c, quantity: q, price: price}, ctx) do
    cond do
      blank?(name) -> raise BusinessException.new(:er400, ctx)
      blank?(type) -> raise BusinessException.new(:er400, ctx)
      blank?(c) -> raise BusinessException.new(:er400, ctx)
      not (type in @types_allowed) -> raise BusinessException.new(:er400, ctx)
      not (c in @currencies_allowed) -> raise BusinessException.new(:er400, ctx)
      not is_integer(q) or q <= 0 -> raise BusinessException.new(:er400, ctx)
      not is_number(price) or price <= 0 -> raise BusinessException.new(:er400, ctx)
      true -> :ok
    end
  end

  defp blank?(v), do: is_nil(v) or (is_binary(v) and String.trim(v) == "")
end
