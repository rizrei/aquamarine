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

  alias Aquamarine.{Guardian, Accounts}

  @spec call(%{refresh_token: String.t()}) :: {:ok, Accounts.session()} | {:error, atom()}
  def call(%{refresh_token: refresh_token}) do
    with {:ok, user, _} <- Guardian.resource_from_token(refresh_token),
         {:ok, _, {new_access_token, %{"jti" => jti}}} <- create_access_token(refresh_token),
         {:ok, _} <- revoke_refresh_token(refresh_token),
         {:ok, new_refresh_token, _} <- create_refresh_token(user, jti) do
      {:ok, %{user: user, access_token: new_access_token, refresh_token: new_refresh_token}}
    end
  end

  def call(_), do: {:error, :token_not_found}

  defp create_access_token(refresh_token) do
    Guardian.exchange(refresh_token, "refresh", "access",
      ttl: Guardian.access_token_ttl(),
      on_verify: false
    )
  end

  def revoke_refresh_token(refresh_token) do
    Guardian.revoke(refresh_token)
  end

  defp create_refresh_token(user, access_token_jti) do
    Guardian.encode_and_sign(
      user,
      %{access_token_jti: access_token_jti},
      token_type: "refresh",
      ttl: Guardian.refresh_token_ttl()
    )
  end
end
