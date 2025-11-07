defmodule AquamarineWeb.GraphQL.Errors do
  def invalid_changeset_error(changeset) do
    {:error, message: "Invalid input params", details: error_details(changeset)}
  end

  def record_not_found_error, do: {:error, message: "Booking not found"}
  def record_not_found_error(record_name), do: {:error, message: "#{record_name} not found"}

  def unauthorized_error, do: {:error, message: "You are not allowed to perform this action"}

  @doc """
  Traverses the changeset errors and returns a map of
  error messages. For example:

  %{start_date: ["can't be blank"], end_date: ["can't be blank"]}
  """
  def error_details(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
