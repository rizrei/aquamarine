defmodule Aquamarine.Vacations.Reviews do
  @moduledoc """
  Context module for managing vacation reviews.

  Provides functions to get and create review
  """
  import Absinthe.Relay.Node, only: [from_global_id: 2]

  alias Aquamarine.Accounts.User
  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Review
  alias AquamarineWeb.GraphQL.Schema

  @doc """
  Get review by id
  """
  def get_review(id), do: Repo.get(Review, id)

  @doc """
  Creates a review for the given user.
  """
  def create_review(%User{} = user, params) do
    with {:ok, place_gid} <- Map.fetch(params, :place_id),
         {:ok, %{id: place_id, type: :place}} <- from_global_id(place_gid, Schema) do
      %Review{}
      |> Review.changeset(%{params | place_id: place_id})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Aquamarine.Repo.insert()
    else
      :error -> {:error, "Invalid place_id"}
      error -> error
    end
  end
end
