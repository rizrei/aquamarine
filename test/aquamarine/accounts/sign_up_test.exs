defmodule Aquamarine.Accounts.SignUpTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  import Ecto.Query

  alias Aquamarine.Accounts.{SignUp, User}

  def get_refresh_token(user_id) do
    "guardian_tokens"
    |> where([gt], gt.sub == ^user_id)
    |> select([gt], gt.jwt)
    |> Repo.one()
  end

  describe "call/1" do
    test "returns new user with tokens" do
      attrs = %{name: "Name", email: "test@mail.com", password: "Passw0rd"}

      assert {:ok, result} = SignUp.call(attrs)
      assert %{user: %User{id: id, email: "test@mail.com"}} = result
      assert %{access_token: _} = result
      assert %{refresh_token: refresh_token} = result
      assert ^refresh_token = get_refresh_token(id)
    end

    test "returns changeset when params invalid" do
      attrs = %{name: "Name", email: "email", password: "Passw0rd"}

      assert {:error, %Ecto.Changeset{} = changeset} = SignUp.call(attrs)
      assert "must have the @ sign and no spaces" in errors_on(changeset).email
    end

    test "returns changeset when user with name already exists" do
      insert(:user, name: "Name")
      attrs = %{name: "Name", email: "test@mail.com", password: "Passw0rd"}

      assert {:error, %Ecto.Changeset{} = changeset} = SignUp.call(attrs)
      assert "has already been taken" in errors_on(changeset).name
    end

    test "returns changeset when user with email already exists" do
      insert(:user, email: "test@mail.com")
      attrs = %{name: "Name", email: "test@mail.com", password: "Passw0rd"}

      assert {:error, %Ecto.Changeset{} = changeset} = SignUp.call(attrs)
      assert "has already been taken" in errors_on(changeset).email
    end
  end
end
