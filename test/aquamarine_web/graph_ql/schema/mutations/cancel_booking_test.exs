defmodule AquamarineWeb.GraphQL.Schema.Mutations.CancelBookingTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation ($id: ID!) {
    cancelBooking(id: $id) {
      id
      state
    }
  }
  """
  test "cancel booking when params valid", %{conn: conn} do
    user = insert(:user)
    place = insert(:place)
    %{id: id} = insert(:booking, user: user, place: place)

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, %{id: id})

    assert %{"data" => %{"cancelBooking" => booking}} = json_response(conn, 200)
    assert %{"id" => ^id, "state" => "canceled"} = booking
  end

  test "return record_not_found error when booking does not exist", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, %{id: Ecto.UUID.generate()})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Record not found" in graphql_error_messages(errors)
  end

  test "return authentication_required error when unauthenticated", %{conn: conn} do
    conn = graphql_query(conn, @mutation, %{id: Ecto.UUID.generate()})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end
end
