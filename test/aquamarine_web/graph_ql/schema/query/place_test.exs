defmodule AquamarineWeb.GraphQL.Schema.Query.PlaceTest do
  use AquamarineWeb.ConnCase, async: true

  alias Aquamarine.Vacations.Place

  @user_query_by_slug """
  query ($slug: String!) {
    place(slug: $slug) {
      name
    }
  }
  """

  @user_query_by_id """
  query ($id: ID!) {
    place(id: $id) {
      name
    }
  }
  """

  test "user_query_by_slug returns the place with a given slug", %{conn: conn} do
    %Place{name: name, slug: slug} = insert(:place)

    conn = graphql_query(conn, @user_query_by_slug, %{slug: slug})

    assert %{"data" => data} = json_response(conn, 200)
    assert %{"place" => %{"name" => ^name}} = data
  end

  test "user_query_by_slug returns error message when record does not exist", %{conn: conn} do
    conn = graphql_query(conn, @user_query_by_slug, %{slug: "slug"})

    assert %{"data" => data, "errors" => errors} = json_response(conn, 200)
    assert %{"place" => nil} = data
    assert "Record not found" in graphql_error_messages(errors)
  end

  @query """
  query ($id: ID, $slug: String) {
    place(id: $id, slug: $slug) {
      name
    }
  }
  """
  test "returns error message when both id and slug provided", %{conn: conn} do
    conn = graphql_query(conn, @query, %{id: "id", slug: "slug"})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "You must provide either `id` or `slug`" in graphql_error_messages(errors)
  end

  @query """
  query {
    place {
      name
    }
  }
  """
  test "returns error message when identificator does not provided", %{conn: conn} do
    conn = graphql_query(conn, @query)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "You must provide either `id` or `slug`" in graphql_error_messages(errors)
  end

  test "user_query_by_id returns the place with a given id", %{conn: conn} do
    %Place{id: id, name: name} = insert(:place)

    conn = graphql_query(conn, @user_query_by_id, %{id: id})

    assert %{"data" => %{"place" => place}} = json_response(conn, 200)
    assert %{"name" => ^name} = place
  end

  test "user_query_by_id returns error message when record does not exist", %{conn: conn} do
    conn = graphql_query(conn, @user_query_by_id, %{id: Ecto.UUID.generate()})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Record not found" in graphql_error_messages(errors)
  end
end
