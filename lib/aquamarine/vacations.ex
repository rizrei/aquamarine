defmodule Aquamarine.Vacations do
  @moduledoc """
  The Vacation context: public interface for finding, booking,
  and reviewing vacation places.
  """

  import Ecto.Query
  alias Aquamarine.Repo

  alias Aquamarine.Vacations.{Place, Booking, Review}
  alias Aquamarine.Accounts.User

  @doc """
  Returns the place with the given `slug`.

  Raises `Ecto.NoResultsError` if no place was found.
  """
  def get_place_by_slug!(slug), do: Repo.get_by!(Place, slug: slug)
  def get_place!(id), do: Repo.get!(Place, id)

  @doc """
  Returns a list of all places.
  """
  def list_places, do: Repo.all(Place)

  @doc """
  Returns the booking with the given `id`.

  Raises `Ecto.NoResultsError` if no booking was found.
  """
  def get_booking!(id), do: Repo.get!(Booking, id)

  @doc """
  Creates a booking for the given user.
  """
  def create_booking(%User{} = user, attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Cancels the given booking.
  """
  def cancel_booking(%Booking{} = booking) do
    booking
    |> Booking.cancel_changeset(%{state: "canceled"})
    |> Repo.update()
  end

  @doc """
  Creates a review for the given user.
  """
  def create_review(%User{} = user, attrs) do
    %Review{}
    |> Review.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  # Dataloader

  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Booking, %{scope: :place, limit: limit}) do
    Booking
    |> where(state: "reserved")
    |> order_by(desc: :start_date)
    |> limit(^limit)
  end

  def query(Booking, %{scope: :user}) do
    Booking
    |> order_by(asc: :start_date)
  end

  def query(queryable, _) do
    queryable
  end
end
