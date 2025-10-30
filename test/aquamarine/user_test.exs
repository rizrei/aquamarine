defmodule Aquamarine.UserTest do
  use Aquamarine.DataCase, async: true

  alias Aquamarine.Accounts.User

  describe "changeset/2" do
    test "required fields to be set" do
      changeset = User.changeset(%User{}, %{})
      required_fields = [:name, :email, :password] |> Enum.sort()

      assert ^required_fields = changeset_required_fields_error(changeset)
    end

    test "validate name length" do
      changeset = User.changeset(%User{}, %{name: "1"})
      assert %{name: ["should be at least 2 character(s)"]} = errors_on(changeset)
    end

    test "validate password length" do
      changeset = User.changeset(%User{}, %{password: "1"})
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end

    test "validates email when given" do
      changeset = User.changeset(%User{}, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates email uniqueness" do
      %{email: email} = insert(:user)
      changeset = User.changeset(%User{}, params_for(:user, %{email: email}))

      assert "has already been taken" in errors_on(changeset).email
      # assert "has already been taken" in errors_on(changeset).name

      # Now try with the upper cased email too, to check that email case is ignored.
      changeset = User.changeset(%User{}, params_for(:user, %{email: String.upcase(email)}))

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates name uniqueness" do
      %{name: name} = insert(:user)
      changeset = User.changeset(%User{}, params_for(:user, %{name: name}))

      assert "has already been taken" in errors_on(changeset).name
    end
  end
end
