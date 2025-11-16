defmodule Aquamarine.Vacations.Reviews do
  @moduledoc """
  Context module for managing vacation reviews.

  Provides functions to get and create review
  """

  alias Aquamarine.Accounts.User
  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Review

  @doc """
  Get review by id
  """
  def get_review(id), do: Repo.get(Review, id)

  @doc """
  Creates a review for the given user.
  """
  def create_review(%User{} = user, attrs) do
    %Review{}
    |> Review.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end
end
