defmodule Products.Shared.Common.Model.Product do
  @enforce_keys [:name, :type, :quantity, :price, :currency]
  defstruct [:id, :name, :type, :quantity, :price, :currency]

  def with_id(%__MODULE__{} = p, id), do: %__MODULE__{p | id: id}
end
