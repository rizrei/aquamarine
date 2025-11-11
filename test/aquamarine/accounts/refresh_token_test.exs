defmodule Aquamarine.Accounts.RefreshTokenTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true, setup_all: :db

  import Ecto.Query
  import Aquamarine.Guardian, only: [encode_and_sign: 3]

  alias Aquamarine.Accounts.RefreshToken

  def get_refresh_token(user_id) do
    "guardian_tokens"
    |> where([gt], gt.sub == ^user_id)
    |> select([gt], gt.jwt)
    |> Repo.one()
  end

  describe "call/1" do
    test "returns user with tokens" do
      user = insert(:user)

      {:ok, refresh_token, _} = encode_and_sign(user, %{}, token_type: "refresh")

      assert {:ok, result} = RefreshToken.call(%{refresh_token: refresh_token})
      assert %{user: %{id: id}} = result
      assert %{access_token: _} = result
      assert %{refresh_token: refresh_token} = result
      assert ^refresh_token = get_refresh_token(id)
    end

    test "returns invalid_token_type error when token is access_token" do
      user = insert(:user)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: "access")

      assert {:error, :invalid_token_type} = RefreshToken.call(%{refresh_token: token})
    end

    test "returns invalid_token error when token is invalid" do
      assert {:error, :invalid_token} = RefreshToken.call(%{refresh_token: "token"})
    end

    test "return token_not_found error when token does not present" do
      assert {:error, :invalid_token} = RefreshToken.call(%{refresh_token: nil})
    end

    test "return token_expired error when token expired" do
      user = insert(:user)

      {:ok, token, _} = encode_and_sign(user, %{}, token_type: "refresh", ttl: {-1, :seconds})

      assert {:error, :token_expired} = RefreshToken.call(%{refresh_token: token})
    end

    test "return record_not_found error when token without record" do
      user = insert(:user)

      {:ok, refresh_token, _} = encode_and_sign(user, %{}, token_type: "refresh")
      Aquamarine.Repo.delete!(user)

      assert {:error, :record_not_found} = RefreshToken.call(%{refresh_token: refresh_token})
    end

    test "return token_not_found error when token deleted" do
      user = insert(:user)

      {:ok, refresh_token, _} = encode_and_sign(user, %{}, token_type: "refresh")

      "guardian_tokens"
      |> where([gt], gt.sub == ^user.id)
      |> Repo.delete_all()

      assert {:error, :token_not_found} = RefreshToken.call(%{refresh_token: refresh_token})
    end

    test "return token_not_found error when invalid attributes" do
      assert {:error, :token_not_found} = RefreshToken.call(%{})
    end
  end
end
