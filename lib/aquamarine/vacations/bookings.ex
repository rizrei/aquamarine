defmodule Aquamarine.Vacations.Bookings do
  alias __MODULE__.Policy
  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Booking
  alias Aquamarine.Accounts.User

  defdelegate authorize(action, user, params), to: Policy

  @doc """
  Get booking by id.
  """
  def get_booking(id), do: Repo.get(Booking, id)

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

  def cancel_booking(%User{} = user, %Booking{} = booking) do
    with :ok <- Bodyguard.permit(Policy, :cancel_booking, user, booking) do
      booking
      |> Booking.cancel_changeset()
      |> Repo.update()
    end
  end
end
