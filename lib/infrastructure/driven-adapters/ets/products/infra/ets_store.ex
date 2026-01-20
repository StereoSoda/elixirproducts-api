defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore do
  @table :products_store

  def table, do: @table

  def init! do
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
        :ok

      _tid ->
        :ok
    end
  end

  def exists?(key) do
    :ets.lookup(@table, key) != []
  end

  def put(key, value) do
    :ets.insert(@table, {key, value})
    :ok
  end

  def values do
    :ets.tab2list(@table) |> Enum.map(fn {_k, v} -> v end)
  end
end
