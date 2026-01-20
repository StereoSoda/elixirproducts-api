defmodule ProductsApi.Domain.Model.Shared.Error do
  @moduledoc false

  defstruct [:code, :http_status, :message, :details, :ctx]

  def er400(ctx, details \\ []),
    do: %__MODULE__{code: "ER400", http_status: 400, message: "Solicitud inválida", details: details, ctx: ctx}

  def er409(ctx, details \\ []),
    do: %__MODULE__{code: "ER409", http_status: 409, message: "Conflicto de negocio", details: details, ctx: ctx}

  def er500(ctx, details \\ []),
    do: %__MODULE__{code: "ER500", http_status: 500, message: "Hay un error interno en el sistema", details: details, ctx: ctx}
end
