defmodule ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy do
  @moduledoc """
  Normaliza textos para construir business keys de forma estable.
  """

  @spec normalize(nil | String.t()) :: String.t()
  def normalize(nil), do: ""

  def normalize(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(~r/[\x{0300}-\x{036F}]/u, "")
    |> String.replace(~r/\s+/u, " ")
  end

  #Unicidad por NAME
  @spec build_key(map()) :: String.t()
  def build_key(%{name: name}) do
    normalize(name)
  end
end
