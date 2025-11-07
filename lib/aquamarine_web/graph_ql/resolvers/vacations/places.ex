defmodule AquamarineWeb.GraphQl.Resolvers.Vacations.Places do
  @moduledoc """
  GraphQL resolvers for Vacation Places.

  Provides fetching a single place by `id` or `slug`, and listing multiple places.
  """

  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Vacations.{Places, Place}

  @doc """
  Get place by id or slug
  """
  @spec place(any(), %{slug: String.t()}, any()) :: {:ok, Place.t()} | {:error, map()}
  def place(_parent, %{slug: slug}, _resolution) do
    case Places.get_place_by_slug(slug) do
      nil -> record_not_found_error()
      place -> {:ok, place}
    end
  end

  @spec place(any(), %{id: Ecto.UUID.t()}, any()) :: {:ok, Place.t()} | {:error, map()}
  def place(_parent, %{id: id}, _resolution) do
    case Places.get_place(id) do
      nil -> record_not_found_error()
      place -> {:ok, place}
    end
  end

  @doc """
  Returns a list of places matching the given `params`.
  """
  @spec places(any(), map(), any()) :: {:ok, [Place.t()]} | {:error, map()}
  def places(_, params, _) do
    case Aquamarine.Vacations.Places.list_places(params) do
      places when is_list(places) -> {:ok, places}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
    end
  end
end
