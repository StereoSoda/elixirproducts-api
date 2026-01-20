defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.ErrorMapper do
  @moduledoc false

  def status(:er400), do: 400
  def status(:er409), do: 409
  def status(:er500), do: 500
  def status(_), do: 500

  def code_str(:er400), do: "ER400"
  def code_str(:er409), do: "ER409"
  def code_str(:er500), do: "ER500"
  def code_str(_), do: "ER500"

  def message(:er400), do: "Hay un error técnico, revisar datos ingresados"
  def message(:er409), do: "Uno de los productos ingresados ya existe en el sistema"
  def message(:er500), do: "Hay un error interno en el sistema"
  def message(_), do: "Hay un error interno en el sistema"
end
