defmodule AquamarineWeb.Schema.Query.MeTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @query """
  {
    me {
      name
      bookings {
        startDate
        endDate
        place {
          id
        }
      }
    }
  }
  """
  test "me query returns my bookings", %{conn: conn} do
    %{id: place_id} = place = insert(:place)
    plase_gid = to_global_id(place_id, :place)
    %{name: name} = user = insert(:user)

    lower = "2025-11-11"
    upper = "2025-11-22"

    insert(:booking,
      user: user,
      place: place,
      period:
        Date.range(
          lower |> Date.from_iso8601() |> then(fn {_, v} -> v end),
          upper |> Date.from_iso8601() |> then(fn {_, v} -> v end)
        )
    )

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@query, %{})

    assert %{"data" => %{"me" => me}} = json_response(conn, 200)
    assert %{"name" => ^name, "bookings" => bookings} = me
    assert [%{"startDate" => ^lower, "endDate" => ^upper, "place" => place1}] = bookings
    assert %{"id" => ^plase_gid} = place1
  end

  test "me query fails if not signed in", %{conn: conn} do
    conn = graphql_query(conn, @query, %{})

    assert %{"data" => %{"me" => nil}} = json_response(conn, 200)
  end
end
