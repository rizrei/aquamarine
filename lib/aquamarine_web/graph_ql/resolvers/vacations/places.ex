defmodule AquamarineWeb.GraphQl.Resolvers.Vacations.Places do
  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Vacations.Places
  alias Aquamarine.Vacations.Place

  def place(_parent, %{slug: slug}, _resolution) do
    case Places.get_place_by_slug(slug) do
      %Place{} = place -> {:ok, place}
      _ -> record_not_found_error()
    end
  end

  def place(_parent, %{id: id}, _resolution) do
    case Places.get_place(id) do
      %Place{} = place -> {:ok, place}
      _ -> record_not_found_error()
    end
  end

  def places(_, params, _) do
    case Aquamarine.Vacations.Places.list_places(params) do
      places when is_list(places) -> {:ok, places}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
    end
  end
end
