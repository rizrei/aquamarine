defmodule AquamarineWeb.GraphQl.Resolvers.Vacations do
  alias Aquamarine.Vacations

  def place(_parent, %{id: _, slug: _}, _resolution) do
    {:error, "You must provide either `id` or `slug`"}
  end

  def place(_parent, %{slug: slug}, _resolution) do
    case Vacations.get_place_by_slug(slug) do
      nil -> {:error, "Place not found"}
      place -> {:ok, place}
    end
  end

  def place(_parent, %{id: id}, _resolution) do
    case Vacations.get_place(id) do
      nil -> {:error, "Place not found"}
      place -> {:ok, place}
    end
  end

  def place(_parent, _, _resolution) do
    {:error, "You must provide either `id` or `slug`"}
  end

  def places(_, params, _) do
    Aquamarine.Vacations.Places.list_places(params)
  end
end
