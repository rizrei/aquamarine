defmodule Aquamarine.Accounts.SignOutTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  import Ecto.Query
  import Aquamarine.Guardian, only: [encode_and_sign: 3]

  alias Aquamarine.Accounts.{SignOut, SignUp}

  def get_refresh_token(user_id) do
    "guardian_tokens"
    |> where([gt], gt.sub == ^user_id)
    |> select([gt], gt.jwt)
    |> Repo.one()
  end

  describe "call/1" do
    test "returns success result" do
      {:ok, %{user: user, access_token: access_token, refresh_token: _refresh_token}} =
        SignUp.call(%{email: "test@mail.com", password: "Passw0rd", name: "Name"})

      assert {:ok, %{success: true}} = SignOut.call(access_token)
      assert nil == get_refresh_token(user.id)
    end

    test "returns invalid_token error when token is refresh_token" do
      {:ok, %{user: _user, access_token: _access_token, refresh_token: refresh_token}} =
        SignUp.call(%{email: "test@mail.com", password: "Passw0rd", name: "Name"})

      assert {:error, :invalid_token_type} = SignOut.call(refresh_token)
    end

    test "return token_expired error when token expired" do
      user = insert(:user)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: "access", ttl: {-1, :seconds})

      assert {:error, :token_expired} = SignOut.call(token)
    end

    test "returns invalid_token error when token is invalid" do
      assert {:error, :invalid_token} = SignOut.call("token")
    end
  end
end
