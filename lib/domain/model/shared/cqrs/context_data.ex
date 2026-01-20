defmodule ProductsApi.Domain.Model.Shared.Cqrs.ContextData do
  @moduledoc """
  Contexto transportado end-to-end: message_id y x_request_id.
  """

  defstruct [:message_id, :x_request_id]

  def empty do
    %__MODULE__{
      message_id: UUID.uuid4(),
      x_request_id: UUID.uuid4()
    }
  end
end
