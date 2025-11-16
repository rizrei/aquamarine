defmodule AquamarineWeb.GraphQL.Resolvers.Vacations.Places do
  @moduledoc """
  GraphQL resolvers for Vacation Places.

  Provides fetching a single place by `id` or `slug`, and listing multiple places.
  """
  import Absinthe.Relay.Node, only: [from_global_id: 2]

  alias Absinthe.Relay.Connection
  alias Aquamarine.Vacations.{Place, Places}
  alias AquamarineWeb.GraphQL.Schema
  alias Places.Queries.ListPlaces

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
    with {:ok, %{id: place_id, type: :place}} <- from_global_id(id, Schema),
         %Place{} = place <- Places.get_place(place_id) do
      {:ok, place}
    else
      nil -> {:error, :not_found}
      error -> error
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
  def places_connection(_parent, params, _resolution) do
    with {:ok, validated_params} <- ListPlaces.Params.validate(params),
         query <- ListPlaces.call(validated_params) do
      Connection.from_query(query, &Aquamarine.Repo.all/1, params)
    end
  end
end
