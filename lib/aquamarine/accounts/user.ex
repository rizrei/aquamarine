defmodule Aquamarine.Accounts.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Aquamarine.Repo
  alias Aquamarine.Vacations.{Booking, Review}

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          email: String.t() | nil,
          password_hash: String.t() | nil,
          password: String.t() | nil,
          bookings: [Booking.t()] | Ecto.Association.NotLoaded.t(),
          reviews: [Review.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true, redact: true

    has_many :bookings, Booking
    has_many :reviews, Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  @email_regex ~r/^[^@,;\s]+@[^@,;\s]+$/
  def changeset(user, attrs) do
    required_fields = [:name, :email, :password]

    user
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> validate_format(:email, @email_regex, message: "must have the @ sign and no spaces")
    |> validate_length(:name, min: 2)
    |> validate_length(:password, min: 6)
    |> unsafe_validate_unique(:email, Repo)
    |> unsafe_validate_unique(:name, Repo)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%__MODULE__{password_hash: password_hash}, password)
      when is_binary(password_hash) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, password_hash)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp put_password_hash(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
