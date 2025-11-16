defmodule AquamarineWeb.GraphQL.Schema.Query.PlacesConnectionTest do
  use AquamarineWeb.ConnCase, async: true

  @query """
  query($first: Int!) {
    placesConnection(first: $first) {
      edges {
        cursor
        node {
          name
        }
      }
    }
  }
  """
  test "placesConnection query returns paginated query", %{conn: conn} do
    %{name: name} = insert(:place)

    conn = graphql_query(conn, @query, %{first: 1})

    assert %{"data" => %{"placesConnection" => places_connection}} = json_response(conn, 200)
    assert %{"edges" => [%{"cursor" => _, "node" => node1}]} = places_connection
    assert %{"name" => ^name} = node1
  end

  @query """
  query {
    placesConnection {
      edges {
        cursor
        node {
          name
        }
      }
    }
  }
  """
  test "return missing first/last error when first/last argument does not provided", %{conn: conn} do
    conn = graphql_query(conn, @query)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "You must either supply `:first` or `:last`" in graphql_error_messages(errors)
  end

  @get_first_query """
  query($first: Int!, $filter: PlaceFilter!) {
    placesConnection(first: $first, filter: $filter) {
      edges {
        cursor
        node {
          name
        }
      }
      pageInfo {
        startCursor
        endCursor
        hasPreviousPage
        hasNextPage
      }
    }
  }
  """
  @cursor_query """
  query($first: Int!, $after: String, $filter: PlaceFilter!) {
    placesConnection(first: $first, after: $after, filter: $filter) {
      edges {
        cursor
        node {
          name
        }
      }
      pageInfo {
        startCursor
        endCursor
        hasPreviousPage
        hasNextPage
      }
    }
  }
  """
  test "places query returns places filtered by name", %{conn: conn} do
    %{name: name1} = insert(:place, max_guests: 4, pet_friendly: true, pool: true, wifi: false)
    %{name: name2} = insert(:place, max_guests: 3, pet_friendly: false, pool: true, wifi: false)
    insert(:place, max_guests: 1)
    insert(:place, pet_friendly: false)
    insert(:place, pool: false)
    insert(:place, wifi: true)

    variables = %{first: 1, filter: %{guest_count: 3, pool: true, wifi: false}}
    conn = graphql_query(conn, @get_first_query, variables)

    assert %{"data" => %{"placesConnection" => places_connection}} = json_response(conn, 200)
    assert %{"edges" => [%{"cursor" => first_cursor, "node" => node1}]} = places_connection
    assert %{"name" => ^name1} = node1
    assert %{"pageInfo" => page_info} = places_connection

    assert %{"startCursor" => ^first_cursor, "hasPreviousPage" => false, "hasNextPage" => true} =
             page_info

    variables = %{
      first: 1,
      after: first_cursor,
      filter: %{guest_count: 3, pool: true, wifi: false}
    }

    conn = graphql_query(conn, @cursor_query, variables)

    assert %{"data" => %{"placesConnection" => places_connection}} = json_response(conn, 200)
    assert %{"edges" => [%{"cursor" => second_cursor, "node" => node1}]} = places_connection
    assert %{"name" => ^name2} = node1
    assert %{"pageInfo" => page_info} = places_connection

    assert %{
             "startCursor" => ^second_cursor,
             "endCursor" => ^second_cursor,
             "hasPreviousPage" => true,
             "hasNextPage" => false
           } =
             page_info
  end
end
