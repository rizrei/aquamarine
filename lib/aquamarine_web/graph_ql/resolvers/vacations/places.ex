defmodule AquamarineWeb.GraphQl.Resolvers.Vacations.Places do
  import AquamarineWeb.GraphQL.ChangesetErrors

  alias Aquamarine.Vacations.Places

  def place(_parent, %{id: _, slug: _}, _resolution) do
    {:error, message: "You must provide either `id` or `slug`"}
  end

  def place(_parent, %{slug: slug}, _resolution) do
    case Places.get_place_by_slug(slug) do
      nil -> {:error, message: "Place not found"}
      place -> {:ok, place}
    end
  end

  def place(_parent, %{id: id}, _resolution) do
    case Places.get_place(id) do
      nil -> {:error, message: "Place not found"}
      place -> {:ok, place}
    end
  end

  def place(_parent, _, _resolution) do
    {:error, message: "You must provide either `id` or `slug`"}
  end

  def places(_, params, _) do
    case Aquamarine.Vacations.Places.list_places(params) do
      places when is_list(places) ->
        {:ok, places}

      {:error, changeset} ->
        {:error, message: "Invalid input params", details: error_details(changeset)}
    end
  end
end
