defmodule Aquamarine.Accounts.SignUp do
  @moduledoc """
  Handles user registration and initial JWT token creation.

  ## Workflow

  - Creates a new user record via `Accounts.register_user/1`.
  - Upon successful registration:
    - Generates an **access token** for immediate authentication.
    - Generates a **refresh token** linked to the access token's JTI.
  - Returns a session-like map with the user and both tokens.

  ## Examples

      iex> Aquamarine.Accounts.SignUp.call(%{
      ...>   name: "Alice",
      ...>   email: "alice@example.com",
      ...>   password: "secret123"
      ...> })
      {:ok, %{user: %User{}, access_token: "...", refresh_token: "..."}}

      iex> Aquamarine.Accounts.SignUp.call(%{email: "bad", password: "short"})
      {:error, %Ecto.Changeset{}}

  Returns:
  - `{:ok, session}` — when the user is successfully registered.
  - `{:error, changeset}` — when validation fails.
  - `{:error, atom}` — if token generation or other unexpected error occurs.
  """
  import Aquamarine.Guardian,
    only: [access_token_ttl: 0, refresh_token_ttl: 0, encode_and_sign: 3]

  alias Aquamarine.Accounts

  @type sign_up_attrs :: %{
          name: String.t(),
          email: String.t(),
          password: String.t()
        }

  @spec call(sign_up_attrs()) ::
          {:ok, Accounts.session()} | {:error, Ecto.Changeset.t()} | {:error, atom()}
  def call(attrs) do
    with {:ok, user} <- Accounts.register_user(attrs),
         {:ok, access_token, %{"jti" => access_token_jti}} <- create_access_token(user),
         {:ok, refresh_token, _} <- create_refresh_token(user, access_token_jti) do
      {:ok, %{user: user, access_token: access_token, refresh_token: refresh_token}}
    end
  end

  defp create_access_token(user) do
    encode_and_sign(user, %{}, token_type: "access", ttl: access_token_ttl())
  end

  defp create_refresh_token(user, access_token_jti) do
    claims = %{access_token_jti: access_token_jti}
    encode_and_sign(user, claims, token_type: "refresh", ttl: refresh_token_ttl())
  end
end
