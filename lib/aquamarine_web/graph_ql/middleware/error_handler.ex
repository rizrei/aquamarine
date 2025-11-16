defmodule AquamarineWeb.GraphQL.Middleware.ErrorHandler do
  @moduledoc """
  GraphQL middleware for centralized error handling in Absinthe.

  This middleware intercepts and normalizes errors returned from resolvers,
  ensuring that all GraphQL responses follow a consistent and client-friendly format.

  """

  @behaviour Absinthe.Middleware

  @impl true
  def call(%{errors: [_ | _] = errors} = resolution, _opts) do
    %{resolution | errors: Enum.flat_map(errors, &handle_error/1)}
  end

  def call(resolution, _opts), do: resolution

  defp handle_error(%Ecto.Changeset{} = changeset) do
    details =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    [%{message: "Invalid input params", details: details}]
  end

  defp handle_error(msg) when is_binary(msg), do: [%{message: msg}]
  defp handle_error(:token_expired), do: [%{message: "Token expired"}]
  defp handle_error(:invalid_token), do: [%{message: "Invalid token"}]
  defp handle_error(:invalid_token_type), do: [%{message: "Invalid token type"}]
  defp handle_error(:token_not_found), do: [%{message: "Token not found"}]
  defp handle_error(:not_found), do: [%{message: "Record not found"}]
  defp handle_error(:unauthenticated), do: [%{message: "Authentication required"}]
  defp handle_error(:unauthorized), do: [%{message: "You are not allowed to perform this action"}]
  defp handle_error(:invalid_params), do: [%{message: "Invalid input params"}]
  defp handle_error(%{message: _} = error), do: [error]
  defp handle_error(message: message), do: [%{message: message}]
  defp handle_error(error), do: [inspect(error)]
end
