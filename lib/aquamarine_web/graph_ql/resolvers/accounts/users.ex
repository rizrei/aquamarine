defmodule AquamarineWeb.GraphQl.Resolvers.Accounts.Users do
  @moduledoc """
  GraphQL resolver for user-related queries.

  Currently, this module provides a single resolver — `me/3`, which returns
  information about the currently authenticated user.

  ## Responsibilities

  - **me/3** — Returns the current user from the GraphQL context if authenticated,
    or `nil` otherwise.
  """

  @spec me(any(), any(), %{context: map()}) :: {:ok, map() | nil}
  def me(_, _, %{context: %{current_user: user}}), do: {:ok, user}
  def me(_, _, _), do: {:ok, nil}
end
