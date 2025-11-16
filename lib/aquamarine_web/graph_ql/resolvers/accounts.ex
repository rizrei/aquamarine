defmodule AquamarineWeb.GraphQL.Resolvers.Accounts do
  @moduledoc """
  GraphQL resolvers for user authentication and session management.

  This module acts as a bridge between GraphQL mutations/queries and the underlying
  `Aquamarine.Accounts` business logic (sign-up, sign-in, sign-out, and token refresh).
  """

  alias Aquamarine.Accounts
  alias Aquamarine.Accounts.{RefreshToken, SignIn, SignOut, SignUp}

  @spec sign_up(any(), SignUp.sign_up_attrs(), any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def sign_up(_, params, _), do: SignUp.call(params)

  @spec sign_in(any(), SignIn.sign_in_attrs(), any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def sign_in(_, params, _), do: SignIn.call(params)

  @spec refresh_token(any(), %{refresh_token: String.t()}, any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def refresh_token(_, params, _), do: RefreshToken.call(params)

  @spec sign_out(any(), any(), %{context: %{access_token: String.t()}}) ::
          {:ok, %{success: boolean()}} | {:error, map()}
  def sign_out(_, _, %{context: %{access_token: token}}), do: SignOut.call(token)
end
