defmodule AquamarineWeb.GraphQL.Schema.Mutations.RefreshTokenTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  import Ecto.Query
  import Aquamarine.Guardian, only: [encode_and_sign: 3]

  alias Aquamarine.Repo

  @mutation """
  mutation ($refreshToken: String!) {
    refreshToken(refreshToken: $refreshToken) {
      user {
        email
      }
      access_token
      refresh_token
    }
  }
  """

  test "return user and token pair when params valid", %{conn: conn} do
    %{email: email} = user = insert(:user)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: "refresh")

    conn = graphql_query(conn, @mutation, %{refreshToken: token})

    assert %{"data" => %{"refreshToken" => session}} = json_response(conn, 200)
    assert %{"user" => %{"email" => ^email}, "access_token" => _, "refresh_token" => _} = session
  end

  test "return invalid_token error when token invalid", %{conn: conn} do
    conn = graphql_query(conn, @mutation, %{refreshToken: "invalid_token"})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid token" in graphql_error_messages(errors)
  end

  test "return expired_token error when token expired", %{conn: conn} do
    user = insert(:user)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: "refresh", ttl: {-1, :second})

    conn = graphql_query(conn, @mutation, %{refreshToken: token})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Refresh token expired" in graphql_error_messages(errors)
  end

  test "return record_not_found error when user does not exist", %{conn: conn} do
    {:ok, token, _} =
      encode_and_sign(%{id: Ecto.UUID.generate()}, %{}, token_type: "refresh")

    conn = graphql_query(conn, @mutation, %{refreshToken: token})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Record not found" in graphql_error_messages(errors)
  end

  test "return invalid_token_type error when token is access_token", %{conn: conn} do
    user = insert(:user)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: "access")

    conn = graphql_query(conn, @mutation, %{refreshToken: token})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid token type" in graphql_error_messages(errors)
  end

  test "return token_not_found error when token deleted", %{conn: conn} do
    user = insert(:user)
    {:ok, token, _} = encode_and_sign(user, %{}, token_type: "refresh")

    "guardian_tokens"
    |> where([gt], gt.sub == ^user.id)
    |> Repo.delete_all()

    conn = graphql_query(conn, @mutation, %{refreshToken: token})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Refresh token not found" in graphql_error_messages(errors)
  end
end
