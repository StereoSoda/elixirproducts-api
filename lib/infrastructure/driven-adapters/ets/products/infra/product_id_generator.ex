defmodule ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.ProductIdGenerator do
  def next_id do
    UUID.uuid4()
  end
end
