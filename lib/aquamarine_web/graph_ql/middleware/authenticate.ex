defmodule AquamarineWeb.GraphQL.Middleware.Authenticate do
  @moduledoc """
  This middleware checks if the `:current_user` key is present in the
  resolution context. If it exists, the request is allowed to proceed.
  Otherwise, it halts the resolution and returns an `Authentication required` error.
  """

  @behaviour Absinthe.Middleware

  @impl true
  def call(%{context: %{current_user: _}} = res, _config), do: res
  def call(res, _config), do: Absinthe.Resolution.put_result(res, error())

  defp error, do: {:error, message: "Authentication required"}
end
