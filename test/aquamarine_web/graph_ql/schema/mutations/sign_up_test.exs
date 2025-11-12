defmodule AquamarineWeb.GraphQL.Schema.Mutations.SignUpTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation ($name: String!, $email: String!, $password: String!) {
    signUp(name: $name, email: $email, password: $password) {
      user {
        email
      }
      access_token
      refresh_token
    }
  }
  """

  test "return user and token pair when params valid", %{conn: conn} do
    variables = %{name: "Name", email: "test@mail.com", password: "password"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"data" => %{"signUp" => session}} = json_response(conn, 200)
    assert %{"user" => user, "access_token" => _, "refresh_token" => _} = session
    assert %{"email" => "test@mail.com"} = user
  end

  test "return error when invalid params", %{conn: conn} do
    variables = %{name: "Name", email: "invalid_email", password: "password"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid input params" in graphql_error_messages(errors)
    assert %{"email" => ["must have the @ sign and no spaces"]} in graphql_error_details(errors)
  end

  test "return error when user already exists", %{conn: conn} do
    insert(:user, name: "Name", email: "test@mail.com")

    variables = %{name: "Name", email: "test@mail.com", password: "password"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid input params" in graphql_error_messages(errors)

    assert %{
             "email" => ["has already been taken"],
             "name" => ["has already been taken"]
           } in graphql_error_details(errors)
  end
end
