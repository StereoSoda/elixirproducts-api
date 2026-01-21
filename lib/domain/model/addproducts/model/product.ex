defmodule ProductsApi.Domain.Model.AddProducts.Model.Product do
  @enforce_keys [:name, :type, :quantity, :price, :currency]
  defstruct [:id, :name, :type, :quantity, :price, :currency]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          name: String.t(),
          type: String.t(),
          quantity: String.t(),
          price: String.t(),
          currency: String.t()
        }

  def with_id(%__MODULE__{} = p, id) when is_binary(id), do: %{p | id: id}

  # Convierte cualquier valor (número o string) a string.
  def from_map!(%{} = m) do
    %__MODULE__{
      id: nil,
      name: to_s(Map.get(m, "name") || Map.get(m, :name)),
      type: to_s(Map.get(m, "type") || Map.get(m, :type)),
      quantity: to_s(Map.get(m, "quantity") || Map.get(m, :quantity)),
      price: to_s(Map.get(m, "price") || Map.get(m, :price)),
      currency: to_s(Map.get(m, "currency") || Map.get(m, :currency))
    }
  end

  def from_map!(_), do: raise "invalid product payload"

  defp to_s(nil), do: ""
  defp to_s(v) when is_binary(v), do: v
  defp to_s(v), do: to_string(v)
end
