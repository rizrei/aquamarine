defmodule AquamarineWeb.GraphQL.Resolvers.Vacations.Reviews do
  @moduledoc """
  GraphQL resolvers for Vacation Places.

  Provides fetching a single place by `id` or `slug`, and listing multiple places.
  """

  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Vacations.{Reviews, Review}

  @doc """
  Creates a new review for place.
  """
  @spec create_review(any(), Review.create_review_attr(), any()) ::
          {:ok, Review.t()} | {:error, map()}
  def create_review(_parent, params, %{context: %{current_user: user}}) do
    case Reviews.create_review(user, params) do
      {:ok, review} -> {:ok, review}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
      {:error, error} -> {:error, message: inspect(error)}
    end
  end
end
