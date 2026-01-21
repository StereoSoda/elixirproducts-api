defmodule ProductsApi.GetProductsIntegrationTest do
  use ExUnit.Case, async: false

  import Plug.Test
  import Plug.Conn

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore

  @opts RouterController.init([])

  setup do
    :ok = EtsStore.init!()

    # Limpia la tabla antes de cada test (evita contaminación entre casos)
    :ets.delete_all_objects(EtsStore.table())

    :ok
  end

  # -----------------------
  # Helpers
  # -----------------------

  defp uuid, do: UUID.uuid4()

  defp req_headers(message_id, x_request_id) do
    [
      {"accept", "application/json"},
      {"content-type", "application/json"},
      {"message-id", message_id},
      {"x-request-id", x_request_id}
    ]
  end

  # Importante: headers debe ser LISTA. No pases Plug.Conn aquí.
  defp dispatch(method, path, body \\ nil, headers \\ []) when is_list(headers) do
    base_conn =
      Plug.Test.conn(method, path, body)
      |> Map.put(:host, "localhost")  # <-- así, NO como header
      |> Map.put(:port, 4000)
      |> Map.put(:scheme, :http)

    conn =
      Enum.reduce(headers, base_conn, fn {k, v}, acc ->
        Plug.Conn.put_req_header(acc, k, v)
      end)

    RouterController.call(conn, @opts)
  end

  defp decode_json!(conn) do
    Jason.decode!(conn.resp_body)
  end

  # Todos los campos como string (según el reto)
  defp product_payload(overrides \\ %{}) do
    base = %{
      "name" => "Papa",
      "type" => "Alimento",
      "quantity" => "3",
      "price" => "3",
      "currency" => "COP"
    }

    Map.merge(base, overrides)
  end

  defp add_products!(products) when is_list(products) do
    mid = uuid()
    rid = uuid()

    body =
      Jason.encode!(%{
        "data" => %{
          "products" => products
        }
      })

    resp =
      dispatch(
        :post,
        "/addProducts",
        body,
        req_headers(mid, rid)
      )

    assert resp.status == 201
    {mid, rid}
  end

  # -----------------------
  # Tests
  # -----------------------

  test "200 cuando se obtienen todos los productos (sin query params)" do
    _ = add_products!([product_payload(%{"name" => "Papa"})])
    _ = add_products!([product_payload(%{"name" => "Arroz"})])

    mid = uuid()
    rid = uuid()

    resp = dispatch(:get, "/getProducts", nil, req_headers(mid, rid))

    assert resp.status == 200
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)

    assert json["meta"]["message-id"] == mid
    assert is_binary(json["meta"]["executionDate"])

    products = json["data"]["products"]
    assert is_list(products)
    assert length(products) == 2

    # Campos como string
    p = hd(products)
    assert is_binary(p["name"])
    assert is_binary(p["type"])
    assert is_binary(p["quantity"])
    assert is_binary(p["price"])
    assert is_binary(p["currency"])
  end

  test "200 cuando se filtra por nombre (any_filter=nombre)" do
    _ = add_products!([product_payload(%{"name" => "Papa"})])
    _ = add_products!([product_payload(%{"name" => "Arroz"})])

    mid = uuid()
    rid = uuid()

    resp =
      dispatch(
        :get,
        "/getProducts?any_filter=nombre&any_value=Papa",
        nil,
        req_headers(mid, rid)
      )

    assert resp.status == 200
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)
    products = json["data"]["products"]

    assert length(products) == 1
    assert hd(products)["name"] == "Papa"
  end

  test "400 cuando any_filter es inválido" do
    _ = add_products!([product_payload()])

    mid = uuid()
    rid = uuid()

    resp =
      dispatch(
        :get,
        "/getProducts?any_filter=invalido&any_value=Papa",
        nil,
        req_headers(mid, rid)
      )

    assert resp.status == 400
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)
    assert json["error"]["code"] == "ER400"
    assert is_binary(json["meta"]["executionDate"])
    assert json["meta"]["message-id"] == mid
  end

  test "409 cuando no se encontraron productos (tabla vacía)" do
    mid = uuid()
    rid = uuid()

    resp = dispatch(:get, "/getProducts", nil, req_headers(mid, rid))

    assert resp.status == 409
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)
    assert json["error"]["code"] == "ER409"
    assert json["meta"]["message-id"] == mid
  end

  test "409 cuando el filtro no retorna resultados" do
    _ = add_products!([product_payload(%{"name" => "Papa"})])

    mid = uuid()
    rid = uuid()

    resp =
      dispatch(
        :get,
        "/getProducts?any_filter=nombre&any_value=NoExiste",
        nil,
        req_headers(mid, rid)
      )

    assert resp.status == 409
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)
    assert json["error"]["code"] == "ER409"
  end

  test "500 cuando ocurre un error desconocido (forzado borrando ETS)" do
    _ = add_products!([product_payload()])

    # Forzamos error: eliminamos la tabla antes del GET
    :ets.delete(EtsStore.table())

    mid = uuid()
    rid = uuid()

    resp = dispatch(:get, "/getProducts", nil, req_headers(mid, rid))

    assert resp.status == 500
    assert get_resp_header(resp, "x-request-id") == [rid]

    json = decode_json!(resp)
    assert json["error"]["code"] == "ER500"
    assert json["meta"]["message-id"] == mid
  end
end
