defmodule Aquamarine.Accounts.RefreshToken do
  @moduledoc """
  Handles refreshing of JWT tokens.

  This module uses `Aquamarine.Guardian` to:
  - Verify and decode the refresh token.
  - Exchange it for a new access token.
  - Revoke the old refresh token.
  - Issue a new refresh token tied to the new access token JTI.

  ## Example

      iex> Aquamarine.Accounts.RefreshToken.call(%{refresh_token: token})
      {:ok, %{user: user, access_token: access_token, refresh_token: refresh_token}}
  """

  import Aquamarine.Guardian

  alias Aquamarine.Accounts

  @spec call(%{refresh_token: String.t()}) :: {:ok, Accounts.session()} | {:error, atom()}
  def call(%{refresh_token: refresh_token}) do
    with {:ok, user, _} <- get_user(refresh_token),
         {:ok, _, {new_access_token, %{"jti" => jti}}} <- create_access_token(refresh_token),
         {:ok, _} <- revoke_refresh_token(refresh_token),
         {:ok, new_refresh_token, _} <- create_refresh_token(user, jti) do
      {:ok, %{user: user, access_token: new_access_token, refresh_token: new_refresh_token}}
    end
  end

  def call(_), do: {:error, :token_not_found}

  defp get_user(refresh_token) do
    case resource_from_token(refresh_token, %{"typ" => "refresh"}) do
      {:ok, _, _} = success -> success
      {:error, "typ"} -> {:error, :invalid_token_type}
      error -> error
    end
  end

  defp create_access_token(refresh_token) do
    exchange(refresh_token, "refresh", "access", ttl: access_token_ttl(), on_verify: false)
  end

  defp revoke_refresh_token(refresh_token) do
    revoke(refresh_token)
  end

  defp create_refresh_token(user, access_token_jti) do
    claims = %{access_token_jti: access_token_jti}
    encode_and_sign(user, claims, token_type: "refresh", ttl: refresh_token_ttl())
  end
end
