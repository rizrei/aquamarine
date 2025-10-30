defmodule Aquamarine.AccountsTest do
  use Aquamarine.DataCase, async: true

  alias Aquamarine.Accounts
  alias Aquamarine.Accounts.User

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "password")
    end

    test "does not return the user if the password is not valid" do
      user = insert(:user)
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = insert(:user)

      assert %User{id: ^id} = Accounts.get_user_by_email_and_password(user.email, user.password)
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "registers a user with valid data" do
      valid_attrs = params_for(:user)

      assert {:ok, %User{} = user} = Accounts.register_user(valid_attrs)
      assert user.email == valid_attrs.email
      assert user.name == valid_attrs.name
      assert Bcrypt.verify_pass(valid_attrs.password, user.password_hash)
    end

    test "does not register a user with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(invalid_attrs)
    end
  end
end
