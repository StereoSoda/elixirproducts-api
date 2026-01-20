defmodule ProductsApi.Domain.Model.AddProducts.Model.Product do
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException
  alias ProductsApi.Domain.Model.Shared.Cqrs.ContextData

  defstruct [:id, :name, :type, :quantity, :price, :currency]

  def from_map!(%{"name" => n, "type" => t, "quantity" => q, "price" => p, "currency" => c}) do
    %__MODULE__{name: n, type: t, quantity: q, price: p, currency: c}
  end

  def from_map!(_), do: raise(BusinessException.new(:er400, ContextData.empty()))

  def with_id(%__MODULE__{} = p, id), do: %__MODULE__{p | id: id}
end
