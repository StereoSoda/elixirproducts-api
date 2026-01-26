defmodule ProductsApi.Domain.Model.AddProducts.Validate.ProductValidator do

  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy

  @types_allowed ["tecnologia", "moda", "alimento"]
  @currency_allowed ["cop"]

  def validate!(product, ctx) do
    name = product.name |> ProductKeyPolicy.normalize()
    type = product.type |> ProductKeyPolicy.normalize()
    currency = product.currency |> ProductKeyPolicy.normalize()

    if name == "" or String.length(name) > 50, do: raise(BusinessException.new(:er400, ctx))
    if type == "" or not (type in @types_allowed), do: raise(BusinessException.new(:er400, ctx))
    if currency == "" or not (currency in @currency_allowed), do: raise(BusinessException.new(:er400, ctx))

    if not is_integer(product.quantity) or product.quantity <= 0,
      do: raise(BusinessException.new(:er400, ctx))

    if not is_integer(product.price) or product.price <= 0,
      do: raise(BusinessException.new(:er400, ctx))

    :ok
  end

end
