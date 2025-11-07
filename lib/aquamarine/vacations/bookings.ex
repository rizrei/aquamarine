defmodule Aquamarine.Vacations.Bookings do
  @moduledoc """
  Context module for managing vacation bookings.

  Provides functions to get, create, and cancel bookings,
  """

  alias __MODULE__.Policy
  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Booking
  alias Aquamarine.Accounts.User

  defdelegate authorize(action, user, params), to: Policy

  @doc """
  Get booking by id.
  """
  @spec get_booking(Ecto.UUID.t()) :: Booking.t() | nil
  def get_booking(id), do: Repo.get(Booking, id)

  @doc """
  Fetch booking by id.
  """
  @spec fetch_booking(Ecto.UUID.t()) :: {:ok, Booking.t()} | {:error, :not_found}
  def fetch_booking(id) do
    case get_booking(id) do
      nil -> {:error, :not_found}
      booking -> {:ok, booking}
    end
  end

  @doc """
  Creates a booking for the given user.
  """
  @spec create_booking(User.t(), Booking.create_booking_attr()) ::
          {:ok, Booking.t()} | {:error, Ecto.Changeset.t()}
  def create_booking(%User{} = user, attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Cancels the given booking.
  """
  @spec cancel_booking(User.t(), Booking.t()) ::
          {:ok, Booking.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def cancel_booking(%User{} = user, %Booking{} = booking) do
    with :ok <- Bodyguard.permit(Policy, :cancel_booking, user, booking) do
      booking
      |> Booking.cancel_changeset()
      |> Repo.update()
    end
  end
end
