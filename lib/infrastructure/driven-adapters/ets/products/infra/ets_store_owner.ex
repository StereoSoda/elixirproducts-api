defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStoreOwner do
  @moduledoc false
  use GenServer

  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    :ok = EtsStore.init!()
    {:ok, %{}}
  end
end
