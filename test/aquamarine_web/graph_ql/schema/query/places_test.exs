defmodule AquamarineWeb.GraphQL.Schema.Query.PlacesTest do
  use AquamarineWeb.ConnCase, async: true

  alias Aquamarine.Vacations.Place

  @query """
  {
    places {
      name
    }
  }
  """
  test "places query returns all places", %{conn: conn} do
    %Place{name: name} = insert(:place)

    conn = graphql_query(conn, @query)

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert [%{"name" => ^name}] = places
  end

  @query """
  query {
    places(limit: 1) {
      name
    }
  }
  """
  test "places query returns limited number of places", %{conn: conn} do
    [%Place{name: name} | _] = insert_list(2, :place)
    conn = graphql_query(conn, @query)

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert [%{"name" => ^name}] = places
  end

  @query """
  query($search: String) {
    places(filter: {search: $search}) {
      name
    }
  }
  """
  test "places query returns places filtered by name", %{conn: conn} do
    %Place{name: name} = insert(:place)

    conn = graphql_query(conn, @query, %{search: name})

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert [%{"name" => ^name}] = places
  end

  @query """
  query {
    places(filter: {search: 123}) {
      name
    }
  }
  """
  test "places query returns an error when using a bad variable value", %{conn: conn} do
    conn = graphql_query(conn, @query)

    error_message =
      "Argument \"filter\" has invalid value {search: 123}.\nIn field \"search\": Expected type \"String\", found 123."

    assert %{"errors" => errors} = json_response(conn, 200)
    assert error_message in graphql_error_messages(errors)
  end

  @query """
  query {
    places(filter: {petFriendly: true, pool: true, wifi: false}) {
      name
    }
  }
  """
  test "places query returns places filtered by pet friendly, pool, wifi", %{conn: conn} do
    %Place{name: name} = insert(:place, pet_friendly: true, pool: true, wifi: false)
    insert(:place, pet_friendly: false)
    insert(:place, pool: false)
    insert(:place, wifi: true)

    conn = graphql_query(conn, @query)

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert [%{"name" => ^name}] = places
  end

  @query """
  query {
    places(filter: {guest_count: 2}) {
      name
    }
  }
  """
  test "places query returns places filtered by guest count", %{conn: conn} do
    %Place{name: name} = insert(:place, max_guests: 3)
    insert(:place, max_guests: 1)

    conn = graphql_query(conn, @query)

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert [%{"name" => ^name}] = places
  end

  @query """
  query ($filter: PlaceFilter!) {
    places(filter: $filter) {
      name
    }
  }
  """
  def build_variables(start_date, end_date) do
    %{
      "filter" => %{
        "available_between" => %{
          start_date: start_date,
          end_date: end_date
        }
      }
    }
  end

  test "places query returns places filtered by available dates", %{conn: conn} do
    %Place{name: name} = place = insert(:place)

    insert(:booking,
      place: place,
      period: Date.range(~D[2025-11-11], ~D[2025-11-15])
    )

    conn1 = graphql_query(conn, @query, build_variables("2025-10-10", "2025-10-15"))
    assert %{"data" => %{"places" => [%{"name" => ^name}]}} = json_response(conn1, 200)

    conn2 = graphql_query(conn, @query, build_variables("2025-11-10", "2025-11-20"))
    assert %{"data" => %{"places" => []}} = json_response(conn2, 200)

    conn3 = graphql_query(conn, @query, build_variables("2025-11-10", "2000-11-20"))
    assert %{"errors" => errors} = json_response(conn3, 200)
    assert "Invalid input params" in graphql_error_messages(errors)

    assert [
             %{
               "filter" => %{
                 "available_between" => %{
                   "start_date" => ["cannot be after :end_date"]
                 }
               }
             }
           ] = graphql_error_details(errors)
  end

  @query """
  query ($orderBy: PlaceOrder!) {
    places(orderBy: $orderBy) {
      name
    }
  }
  """
  test "places query returns places descending", %{conn: conn} do
    ["Place 3", "Place 1", "Place 2"] |> Enum.each(fn name -> insert(:place, name: name) end)

    conn = graphql_query(conn, @query, %{orderBy: %{name: "ASC"}})

    assert %{"data" => %{"places" => places}} = json_response(conn, 200)
    assert ["Place 1", "Place 2", "Place 3"] = Enum.map(places, fn p -> p["name"] end)
  end
end
