defmodule ProductsApi.Domain.Model.Shared.Exception.BusinessException do
  @moduledoc false

  defexception [:code, :context, :reason, :field]

  @type t :: %__MODULE__{
          code: atom(),
          context: any(),
          reason: atom() | nil,
          field: String.t() | nil
        }

  @impl true
  def message(%__MODULE__{code: code, reason: reason, field: field}) do
    "BusinessException code=#{inspect(code)} reason=#{inspect(reason)} field=#{inspect(field)}"
  end

  def new(code, ctx, reason \\ nil, field \\ nil) do
    %__MODULE__{code: code, context: ctx, reason: reason, field: field}
  end
end
