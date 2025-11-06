defmodule Aquamarine.Vacations.Places do
  alias Aquamarine.Vacations.Place
  alias Aquamarine.Vacations.Queries.Places
  alias Aquamarine.Vacations.Queries.Places.Params

  @doc """
  Returns a list of places matching the given `criteria`.

  Example Criteria:
  %{
    filter: %{
      pool: true,
      search: "Starry Yurt",
      available_between: %{end_date: ~D[2025-09-09], start_date: ~D[2025-09-08]},
      guest_count: 1,
      wifi: true
    },
    limit: 5,
    order_by: %{name: :asc, max_guests: :desc}
  }
  """

  @spec list_places(map()) :: {:ok, [Place.t()]} | {:error, Ecto.Changeset.t()}
  def list_places(params) do
    with {:ok, result} <- Params.validate(params) do
      {:ok, Places.list_places(result)}
    end
  end
end
