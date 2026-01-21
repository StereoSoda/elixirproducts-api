defmodule ProductsApi.Domain.Model.Shared.Cqrs.Query do
  @moduledoc false

  alias ProductsApi.Domain.Model.Shared.Cqrs.ContextData

  @enforce_keys [:params, :context]
  defstruct [:params, :context]

  @type t :: %__MODULE__{
          params: map(),
          context: ContextData.t(),
          context: any()
        }
end
