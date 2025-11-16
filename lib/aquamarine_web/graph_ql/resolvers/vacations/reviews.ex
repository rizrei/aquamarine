defmodule AquamarineWeb.GraphQL.Resolvers.Vacations.Reviews do
  @moduledoc """
  GraphQL resolvers for Vacation Places.

  Provides fetching a single place by `id` or `slug`, and listing multiple places.
  """

  alias Aquamarine.Vacations.{Review, Reviews}

  @doc """
  Creates a new review for place.
  """
  @spec create_review(any(), Review.create_review_attr(), any()) ::
          {:ok, Review.t()} | {:error, map()}
  def create_review(_parent, params, %{context: %{current_user: user}}) do
    Reviews.create_review(user, params)
  end
end
