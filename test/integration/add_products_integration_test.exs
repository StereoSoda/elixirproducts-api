defmodule ProductsApi.AddProductsIntegrationTest do
  use ExUnit.Case, async: false

  import Plug.Test
  import Plug.Conn

  alias ProductsApi.Infrastructure.EntryPoints.ProductsApiController.RouterController
  alias ProductsApi.Infrastructure.DrivenAdapters.Ets.Products.Infra.EtsStore

  @endpoint "/addProducts"

  @h_message_id "message-id"
  @h_x_request_id "x-request-id"

  @msg_201 "Los productos fueron guardados exitosamente"
  @msg_400 "Hay un error técnico, revisar datos ingresados"
  @msg_409 "Uno de los productos ingresados ya existe en el sistema"
  @msg_500 "Hay un error interno en el sistema"

  setup do
    # Asegura ETS lista (por si el test corre sin levantar server)
    :ok = EtsStore.init!()

    # Limpia tabla entre tests
    if :ets.whereis(EtsStore.table()) != :undefined do
      :ets.delete_all_objects(EtsStore.table())
    end

    :ok
  end

  test "201 cuando se guardó exitosamente la petición" do
    mid = uuid()
    xrid = uuid()

    body =
      ~s({
        "data": {
          "products": [
            { "name":"Papa", "type":"Alimento", "quantity":"3", "price":"3", "currency":"COP" }
          ]
        }
      })

    conn =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn.status == 201
    assert_resp_header(conn, @h_x_request_id, xrid)

    json = Jason.decode!(conn.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "creationDate"]))
    assert get_in(json, ["data", "message"]) == @msg_201
  end

  test "400 cuando falta algún parámetro (products)" do
    mid = uuid()
    xrid = uuid()

    body = ~s({ "data": { } })

    conn =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn.status == 400
    assert_resp_header(conn, @h_x_request_id, xrid)

    json = Jason.decode!(conn.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "executionDate"]))
    assert get_in(json, ["error", "code"]) == "ER400"
    assert get_in(json, ["error", "message"]) == @msg_400
  end

  test "400 cuando hay valor inválido (type inválido)" do
    mid = uuid()
    xrid = uuid()

    body =
      ~s({
        "data": {
          "products": [
            { "name":"Papa", "type":"INVALIDO", "quantity":"3", "price":"3", "currency":"COP" }
          ]
        }
      })

    conn =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn.status == 400
    assert_resp_header(conn, @h_x_request_id, xrid)

    json = Jason.decode!(conn.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "executionDate"]))
    assert get_in(json, ["error", "code"]) == "ER400"
    assert get_in(json, ["error", "message"]) == @msg_400
  end

  test "400 cuando se duplica la información en la lista" do
    mid = uuid()
    xrid = uuid()

    body =
      ~s({
        "data": {
          "products": [
            { "name":"Papa", "type":"Alimento", "quantity":"3", "price":"3", "currency":"COP" },
            { "name":"Papa", "type":"Alimento", "quantity":"3", "price":"3", "currency":"COP" }
          ]
        }
      })

    conn =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn.status == 400
    assert_resp_header(conn, @h_x_request_id, xrid)

    json = Jason.decode!(conn.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "executionDate"]))
    assert get_in(json, ["error", "code"]) == "ER400"
    assert get_in(json, ["error", "message"]) == @msg_400
  end

  test "409 cuando el producto ya existe" do
    mid = uuid()
    xrid = uuid()

    body =
      ~s({
        "data": {
          "products": [
            { "name":"Papa", "type":"Alimento", "quantity":"3", "price":"3", "currency":"COP" }
          ]
        }
      })

    # 1) Inserta OK
    conn1 =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn1.status == 201

    # 2) Reintenta = 409
    conn2 =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn2.status == 409
    assert_resp_header(conn2, @h_x_request_id, xrid)

    json = Jason.decode!(conn2.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "executionDate"]))
    assert get_in(json, ["error", "code"]) == "ER409"
    assert get_in(json, ["error", "message"]) == @msg_409
  end

  test "500 cuando ocurre un error desconocido (forzado por ETS ausente)" do
    mid = uuid()
    xrid = uuid()

    # Borra la tabla ETS antes del request.
    if :ets.whereis(EtsStore.table()) != :undefined do
      :ets.delete(EtsStore.table())
    end

    body =
      ~s({
        "data": {
          "products": [
            { "name":"Papa", "type":"Alimento", "quantity":"3", "price":"3", "currency":"COP" }
          ]
        }
      })

    conn =
      post_json(@endpoint, body, mid, xrid)
      |> call_router()

    assert conn.status == 500
    assert_resp_header(conn, @h_x_request_id, xrid)

    json = Jason.decode!(conn.resp_body)
    assert get_in(json, ["meta", "message-id"]) == mid
    assert is_binary(get_in(json, ["meta", "executionDate"]))
    assert get_in(json, ["error", "code"]) == "ER500"
    assert get_in(json, ["error", "message"]) == @msg_500
  end

  # -----------------------
  # Helpers
  # -----------------------

  defp call_router(conn), do: RouterController.call(conn, RouterController.init([]))

  defp post_json(path, body, mid, xrid) do
    conn(:post, path, body)
    |> put_req_header("content-type", "application/json")
    |> put_req_header("accept", "application/json")
    |> put_req_header(@h_message_id, mid)
    |> put_req_header(@h_x_request_id, xrid)
  end

  defp assert_resp_header(conn, header, expected) do
    actual = conn |> get_resp_header(header) |> List.first()
    assert actual == expected
  end

  defp uuid(), do: UUID.uuid4()
end
