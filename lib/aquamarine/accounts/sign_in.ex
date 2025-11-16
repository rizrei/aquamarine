defmodule Aquamarine.Accounts.SignIn do
  @moduledoc """
  Handles user authentication and JWT token creation.

  ## Workflow

  - Validates user credentials (`email` and `password`) via `Accounts.get_user_by_email_and_password/2`.
  - If credentials are valid:
    - Generates a new **access token** with type `"access"`.
    - Generates a linked **refresh token** with type `"refresh"` and embeds the access token's JTI.
  - Returns both tokens and the user in a session-like structure.

  ## Examples

      iex> Aquamarine.Accounts.SignIn.call(%{email: "user@example.com", password: "secret"})
      {:ok, %{user: %User{}, access_token: "...", refresh_token: "..."}}

      iex> Aquamarine.Accounts.SignIn.call(%{email: "wrong@example.com", password: "oops"})
      {:error, :record_not_found}
  """
  import Aquamarine.Guardian,
    only: [access_token_ttl: 0, refresh_token_ttl: 0, encode_and_sign: 3]

  alias Aquamarine.Accounts

  @type sign_in_attrs :: %{email: String.t(), password: String.t()}

  @spec call(sign_in_attrs()) :: {:ok, Accounts.session()} | {:error, atom()}
  def call(params) do
    with {:ok, user} <- get_user(params),
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

  defp get_user(%{email: email, password: password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  defp get_user(_), do: {:error, :not_found}
end
