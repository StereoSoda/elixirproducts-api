defmodule ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy do
  @moduledoc """
  Normaliza textos para construir business keys (name|type|currency) de forma estable.
  - trim
  - downcase
  - quita tildes/diacríticos
  - colapsa espacios
  """

  @spec normalize(nil | String.t()) :: String.t()
  def normalize(nil), do: ""

  def normalize(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.normalize(:nfd)
    # Remueve diacríticos combinantes (tildes)
    |> String.replace(~r/[\x{0300}-\x{036F}]/u, "")
    # Colapsa espacios internos
    |> String.replace(~r/\s+/u, " ")
  end

  @spec build_key(map()) :: String.t()
  def build_key(%{name: name, type: type, currency: currency}) do
    Enum.join([normalize(name), normalize(type), normalize(currency)], "|")
  end
end
