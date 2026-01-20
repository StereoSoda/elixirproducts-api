defmodule ProductsApi.Domain.UseCase.AddProducts.AddProductsUseCase do
  @moduledoc """
  Caso de uso: AddProducts

  - Extrae payload y contexto (CQRS Command)
  - Valida negocio en el dominio
  - Valida duplicados dentro del request (misma business key)
  - Verifica existencia previa en el storage (409)
  - Persiste en storage
  """

  alias ProductsApi.Domain.Model.Shared.Cqrs.Command
  alias ProductsApi.Domain.Model.Shared.Cqrs.ContextData
  alias ProductsApi.Domain.Model.Shared.Exception.BusinessException

  alias ProductsApi.Domain.Model.AddProducts.Model.Product
  alias ProductsApi.Domain.Model.Shared.Common.Model.ProductKeyPolicy
  alias ProductsApi.Domain.Model.Shared.Common.Validate.ProductValidate

  @spec execute(Command.t(), module()) :: :ok | no_return()
  def execute(%Command{payload: payload, context: %ContextData{} = ctx}, repo_mod) when is_atom(repo_mod) do
    products =
      payload
      |> extract_products!(ctx)
      |> Enum.map(&Product.from_map!/1)

    # 0) Lista vacía = 400 (según escenarios del reto)
    if products == [] do
      raise(BusinessException.new(:er400, ctx))
    end

    # 1) Validaciones de dominio (campos, reglas, allowed values, etc.)
    Enum.each(products, &ProductValidate.validate!(&1, ctx))

    # 2) Duplicados en la misma request (400)
    keys = Enum.map(products, &ProductKeyPolicy.build_key/1)

    if has_duplicates?(keys) do
      raise(BusinessException.new(:er400, ctx))
    end

    # 3) Ya existe en storage (409) - se consulta por business key
    if Enum.any?(keys, fn key -> exists?(repo_mod, key) end) do
      raise(BusinessException.new(:er409, ctx))
    end

    # 4) Persistencia
    case repo_mod.save_all(products) do
      :ok -> :ok
      {:error, _reason} -> raise(BusinessException.new(:er500, ctx))
      other when other in [:error, false, nil] -> raise(BusinessException.new(:er500, ctx))
      _ -> :ok
    end
  end

  # --------------------
  # Helpers
  # --------------------

  # Soporta payload con forma: %{"data" => %{"products" => [...]}}
  defp extract_products!(%{"data" => %{"products" => products}}, _ctx) when is_list(products), do: products

  # Soporta payload con forma: %{data: %{products: [...]}} (si llega atomizado)
  defp extract_products!(%{data: %{products: products}}, _ctx) when is_list(products), do: products

  # Soporta payload ya “plano” si tu mapper lo deja así: %{"products" => [...]}
  defp extract_products!(%{"products" => products}, _ctx) when is_list(products), do: products
  defp extract_products!(%{products: products}, _ctx) when is_list(products), do: products

  defp extract_products!(_, ctx), do: raise(BusinessException.new(:er400, ctx))

  defp has_duplicates?(list) do
    list
    |> Enum.frequencies()
    |> Enum.any?(fn {_k, count} -> count > 1 end)
  end

  # Adapter-agnostic: soporta boolean o {:ok, boolean}
  defp exists?(repo_mod, key) do
    case repo_mod.exists_by_key(key) do
      true -> true
      false -> false
      {:ok, true} -> true
      {:ok, false} -> false
      _ -> false
    end
  end
end
