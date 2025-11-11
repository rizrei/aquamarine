defmodule AquamarineWeb.Plugs.SetCurrentUserTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  alias Aquamarine.Guardian
  alias Aquamarine.Accounts.User
  alias AquamarineWeb.Plugs.SetCurrentUser

  describe "call/2" do
    test "sets current_user and access_token in context with valid token", %{conn: conn} do
      %User{id: id} = user = insert(:user)
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{typ: "access"})

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/graphql")
        |> SetCurrentUser.call([])

      assert %{private: %{absinthe: %{context: context}}} = conn
      assert %{access_token: ^token, current_user: %User{id: ^id}} = context
    end

    test "returns empty context when no token provided", %{conn: conn} do
      conn =
        conn
        |> post("/graphql")
        |> SetCurrentUser.call([])

      assert %{private: %{absinthe: %{context: %{}}}} = conn
    end

    test "returns empty context when token is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid_token")
        |> post("/graphql")
        |> SetCurrentUser.call([])

      assert %{private: %{absinthe: %{context: %{}}}} = conn
    end

    test "returns empty context when token is refresh_token", %{conn: conn} do
      user = insert(:user)
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{typ: "refresh"})

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post("/graphql")
        |> SetCurrentUser.call([])

      assert %{private: %{absinthe: %{context: %{}}}} = conn
    end
  end
end
