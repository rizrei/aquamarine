defmodule Aquamarine.Vacations.Places do
  @moduledoc """
  High–level operations for working with vacation places.

  This module provides convenient interface functions for loading a single
  place or listing a collection of places with filtering, ordering and limits.
  """

  import Ecto.Query

  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Place
  alias Aquamarine.Vacations.Places.Queries.ListPlaces
  alias Aquamarine.Vacations.Places.Queries.ListPlaces.Params

  @doc """
  Fetches a place by its slug.

  ## Examples

      iex> get_place_by_slug("starry-yurt")
      %Place{...}

      iex> get_place_by_slug("not-found")
      nil
  """
  @spec get_place_by_slug(String.t()) :: Place.t() | nil
  def get_place_by_slug(slug), do: Repo.get_by(Place, slug: slug)

  @doc """
  Fetches a place by its ID.

  ## Examples

      iex> get_place(5e06169c-063d-4d4e-b35e-8c121f93f768)
      %Place{id: 5e06169c-063d-4d4e-b35e-8c121f93f768, ...}

      iex> get_place(966ebf79-c36d-4ad7-a3b9-4aa927622ff7)
      nil
  """
  @spec get_place(Ecto.UUID.t()) :: Place.t() | nil
  def get_place(id), do: Repo.get(Place, id)

  @doc """
  Returns a list of places matching the given `criteria`.

  ## Parameters

    * `:filter` — optional filtering options
    * `:limit` — maximum number of results
    * `:order_by` — sorting definition

  ## Example Criteria

      %{
        filter: %{
          pool: true,
          search: "Starry Yurt",
          available_between: %{start_date: ~D[2025-09-08], end_date: ~D[2025-09-09]},
          guest_count: 1,
          wifi: true
        },
        limit: 5,
        order_by: %{name: :asc, max_guests: :desc}
      }

  ## Examples

      iex> list_places(%{limit: 2})
      {:ok, [%Place{}, %Place{}]}

      iex> list_places(%{filter: %{pool: true}})
      {:ok, [%Place{}, ...]}

      iex> list_places(%{filter: %{guest_count: "wrong type"}})
      {:error, %Ecto.Changeset{}}

  """

  @spec list_places(map()) :: [Place.t()] | {:error, Ecto.Changeset.t()}
  def list_places(params) do
    with {:ok, result} <- Params.validate(params) do
      ListPlaces.call(result)
    end
  end
end
