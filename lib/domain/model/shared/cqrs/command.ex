defmodule ProductsApi.Domain.Model.Shared.Cqrs.Command do
  @enforce_keys [:payload, :context]
  defstruct [:payload, :context]
end
