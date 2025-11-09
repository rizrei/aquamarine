defmodule AquamarineWeb.GraphQL.Errors do
  @moduledoc """
  Helper functions for returning standardized GraphQL error tuples.

  This module is intended to keep error responses consistent across resolvers.
  It provides helpers for:
    * Returning a generic invalid changeset error with field-level details.
    * Returning a standardized "record not found" error.
    * Returning a standardized "unauthorized" error.
    * Extracting human-readable field errors from an `Ecto.Changeset`.

  All functions return errors in the format expected by Absinthe resolvers:

      {:error, message: "...", details: ...}

  Example usage in a resolver:

      case MyContext.create(params) do
        {:ok, result} -> {:ok, result}
        {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
      end
  """

  @spec invalid_changeset_error(Ecto.Changeset.t()) ::
          {:error, message: String.t(), details: map()}
  def invalid_changeset_error(changeset) do
    {:error, message: "Invalid input params", details: error_details(changeset)}
  end

  @spec record_not_found_error :: {:error, message: String.t()}
  def record_not_found_error, do: {:error, message: "Record not found"}
  def record_not_found_error(record_name), do: {:error, message: "#{record_name} not found"}

  @spec unauthorized_error :: {:error, message: String.t()}
  def unauthorized_error, do: {:error, message: "You are not allowed to perform this action"}

  @doc """
  Traverses the changeset errors and returns a map of
  error messages. For example:

  %{start_date: ["can't be blank"], end_date: ["can't be blank"]}
  """
  @spec error_details(Ecto.Changeset.t()) :: map()
  def error_details(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
