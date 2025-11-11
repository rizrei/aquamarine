defmodule AquamarineWeb.GraphQL.Schema.Mutations.SignInTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation ($email: String!, $password: String!) {
    signIn(email: $email, password: $password) {
      user {
        email
      }
      access_token
      refresh_token
    }
  }
  """

  test "return user and token pair when params valid", %{conn: conn} do
    variables = %{email: "test@mail.com", password: "Passw0rd"}

    insert(:user, email: variables.email, password_hash: Bcrypt.hash_pwd_salt(variables.password))

    conn = graphql_query(conn, @mutation, variables)

    assert %{"data" => %{"signIn" => session}} = json_response(conn, 200)
    assert %{"user" => user, "access_token" => _, "refresh_token" => _} = session
    assert %{"email" => "test@mail.com"} = user
  end

  test "return record_not_found when invalid password", %{conn: conn} do
    variables = %{email: "test@mail.com", password: "Passw0rd"}

    insert(:user, email: variables.email, password_hash: Bcrypt.hash_pwd_salt("PASSWORD"))

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Record not found" in graphql_error_messages(errors)
  end
end
