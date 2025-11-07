defmodule Aquamarine.Vacations do
  @moduledoc """
  The Vacation context: public interface for finding, booking,
  and reviewing vacation places.
  """

  alias Aquamarine.Repo

  alias Aquamarine.Vacations.Review
  alias Aquamarine.Accounts.User

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
