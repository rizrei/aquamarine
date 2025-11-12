defmodule Aquamarine.Accounts.SignOut do
  @moduledoc """
  Handles user sign-out by revoking refresh tokens linked to an access token.
  """

  import Ecto.Query

  alias Aquamarine.{Repo, Guardian}

  @spec call(String.t()) :: {:ok, %{success: true}} | {:error, atom()}
  def call(access_token) do
    with {:ok, %{"jti" => access_token_jti}} <- decode_and_verify_token(access_token),
         {:ok, _} <- revoke_related_refresh_token(access_token_jti) do
      {:ok, %{success: true}}
    else
      {:error, "typ"} -> {:error, :invalid_token_type}
      error -> error
    end
  end

  def decode_and_verify_token(access_token) do
    Guardian.decode_and_verify(access_token, %{"typ" => "access"})
  end

  defp revoke_related_refresh_token(access_token_jti) do
    "guardian_tokens"
    |> where([gt], fragment("?->>'access_token_jti' = ?", gt.claims, ^access_token_jti))
    |> Repo.delete_all()

    {:ok, :deleted}
  end
end
