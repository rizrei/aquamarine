defmodule Aquamarine.Accounts.SignInTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  import Ecto.Query

  alias Aquamarine.Accounts.{SignIn, User}

  def get_refresh_token(user_id) do
    "guardian_tokens"
    |> where([gt], gt.sub == ^user_id)
    |> select([gt], gt.jwt)
    |> Repo.one()
  end

  describe "call/1" do
    test "returns user with tokens" do
      attrs = %{email: "test@mail.com", password: "Passw0rd"}

      %User{id: id} =
        insert(:user, email: attrs.email, password_hash: Bcrypt.hash_pwd_salt(attrs.password))

      assert {:ok, result} = SignIn.call(attrs)
      assert %{user: %User{id: ^id}} = result
      assert %{access_token: _} = result
      assert %{refresh_token: refresh_token} = result
      assert ^refresh_token = get_refresh_token(id)
    end

    test "returns not_found when invalid password" do
      attrs = %{email: "test@mail.com", password: "Passw0rd"}

      insert(:user, email: attrs.email, password_hash: Bcrypt.hash_pwd_salt("Passw0rdPassw0rd"))

      assert {:error, :not_found} = SignIn.call(attrs)
    end

    test "returns not_found when invalid email" do
      attrs = %{email: "test@mail.com", password: "Passw0rd"}

      insert(:user, email: "foo@mail.com", password_hash: Bcrypt.hash_pwd_salt(attrs.password))

      assert {:error, :not_found} = SignIn.call(attrs)
    end

    test "returns not_found when params empty" do
      assert {:error, :not_found} = SignIn.call(%{})
    end
  end
end
