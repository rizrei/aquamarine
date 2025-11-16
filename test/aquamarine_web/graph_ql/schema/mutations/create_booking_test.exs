defmodule AquamarineWeb.GraphQL.Schema.Mutations.CreateBookingTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation ($placeId: ID!, $startDate: Date!, $endDate: Date!) {
    createBooking(placeId: $placeId, startDate: $startDate, endDate: $endDate) {
      startDate
      endDate
      state
      place {
        id
      }
    }
  }
  """
  test "create booking when params valid", %{conn: conn} do
    user = insert(:user)
    place_gid = insert(:place) |> to_global_id(:place)

    variables = %{placeId: place_gid, startDate: "2025-11-11", endDate: "2025-11-15"}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"data" => %{"createBooking" => booking}} = json_response(conn, 200)

    assert %{
             "startDate" => "2025-11-11",
             "endDate" => "2025-11-15",
             "state" => "reserved",
             "place" => %{"id" => ^place_gid}
           } = booking
  end

  test "return error when place_id is internal place id", %{conn: conn} do
    user = insert(:user)
    place_gid = insert(:place) |> to_global_id(:place)

    variables = %{placeId: place_gid, startDate: "2025-11-11", endDate: "2025-01-01"}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid input params" in graphql_error_messages(errors)
    assert %{"start_date" => ["cannot be after :end_date"]} in graphql_error_details(errors)
  end

  test "return authentication_required error when unauthenticated", %{conn: conn} do
    variables = %{placeId: Ecto.UUID.generate(), startDate: "2025-11-11", endDate: "2025-01-01"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end

  test "return authentication_required when invaid token", %{conn: conn} do
    variables = %{placeId: Ecto.UUID.generate(), startDate: "2025-11-11", endDate: "2025-01-01"}

    conn =
      conn
      |> put_req_header("authorization", "Bearer token")
      |> graphql_query(@mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end

  test "return authentication_required error when token expired", %{conn: conn} do
    user = insert(:user)
    %{id: place_id} = insert(:place)

    variables = %{placeId: place_id, startDate: "2025-11-11", endDate: "2025-01-01"}

    {:ok, expired_token, _} =
      Aquamarine.Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {-1, :seconds})

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{expired_token}")
      |> graphql_query(@mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end
end
