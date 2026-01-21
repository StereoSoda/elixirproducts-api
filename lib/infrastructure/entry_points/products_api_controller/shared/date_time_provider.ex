defmodule ProductsApi.Infrastructure.EntryPoints.ProductsApiController.Shared.DateTimeProvider do
  @moduledoc false

  # Formato requerido: "26/12/2025 02:26:02:262"

  def now_formatted do
    dt = DateTime.utc_now()

    base =
      dt
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:millisecond)
      |> NaiveDateTime.to_erl()

    {{y, mo, d}, {h, mi, s}} = base

    ms =
      dt.microsecond
      |> elem(0)
      |> div(1000)

    :io_lib.format("~2..0B/~2..0B/~4..0B ~2..0B:~2..0B:~2..0B:~3..0B", [d, mo, y, h, mi, s, ms])
    |> IO.iodata_to_binary()
  end
end
