defmodule AquamarineWeb.GraphQL.Schema.Mutations.SignOutTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation {
    signOut {
      success
    }
  }
  """

  test "return success true when user exist", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, %{})

    assert %{"data" => %{"signOut" => %{"success" => true}}} = json_response(conn, 200)
  end

  test "return authentication_required error when unauthenticated", %{conn: conn} do
    conn = graphql_query(conn, @mutation, %{})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end

  test "return authentication_required when invaid token", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer token")
      |> graphql_query(@mutation, %{})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end

  test "return authentication_required error when token expired", %{conn: conn} do
    user = insert(:user)

    {:ok, expired_token, _} =
      Aquamarine.Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {-1, :seconds})

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{expired_token}")
      |> graphql_query(@mutation, %{})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end

  test "return authentication_required error when token is refresh_token", %{conn: conn} do
    user = insert(:user)

    {:ok, token, _} = Aquamarine.Guardian.encode_and_sign(user, %{}, token_type: "refresh")

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> graphql_query(@mutation, %{})

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end
end
