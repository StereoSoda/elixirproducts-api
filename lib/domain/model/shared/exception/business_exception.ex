defmodule ProductsApi.Domain.Model.Shared.Exception.BusinessException do
  @moduledoc """
  Excepción de negocio con código y contexto (message_id / x_request_id).
  """

  defexception [:code, :context, :message]

  @type t :: %__MODULE__{
          code: atom(),
          context: term(),
          message: String.t() | nil
        }

  # Helper para mantener el estilo que vienes usando: BusinessException.new(:er400, ctx)
  def new(code, context, message \\ nil) when is_atom(code) do
    %__MODULE__{code: code, context: context, message: message}
  end

  @impl true
  def message(%__MODULE__{message: nil, code: code}), do: Atom.to_string(code)
  def message(%__MODULE__{message: msg}), do: msg
end
