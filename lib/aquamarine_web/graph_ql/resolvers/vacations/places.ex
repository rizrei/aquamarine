defmodule AquamarineWeb.GraphQL.Resolvers.Vacations.Places do
  @moduledoc """
  GraphQL resolvers for Vacation Places.

  Provides fetching a single place by `id` or `slug`, and listing multiple places.
  """

  alias Aquamarine.Vacations.{Places, Place}

  @doc """
  Get place by id or slug
  """
  @spec place(any(), %{slug: String.t()}, any()) :: {:ok, Place.t()} | {:error, map()}
  def place(_parent, %{slug: slug}, _resolution) do
    case Places.get_place_by_slug(slug) do
      nil -> {:error, :not_found}
      place -> {:ok, place}
    end
  end

  @spec place(any(), %{id: Ecto.UUID.t()}, any()) :: {:ok, Place.t()} | {:error, map()}
  def place(_parent, %{id: id}, _resolution) do
    case Places.get_place(id) do
      nil -> {:error, :not_found}
      place -> {:ok, place}
    end
  end

  @doc """
  Returns a list of places matching the given `params`.
  """
  @spec places(any(), map(), any()) :: {:ok, [Place.t()]} | {:error, map()}
  def places(_, params, _) do
    case Places.list_places(params) do
      places when is_list(places) -> {:ok, places}
      error -> error
    end
  end

  @doc """
  Returns a list of places relay connections.
  """
  @spec places_connection(any(), map(), any()) ::
          {:ok, Absinthe.Relay.Connection.t()} | {:error, map()}
  def places_connection(parent, params, resolution) do
    with {:ok, places} <- places(parent, params, resolution) do
      Absinthe.Relay.Connection.from_list(places, params)
    end
  end
end
