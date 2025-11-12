defmodule AquamarineWeb.GraphQL.Resolvers.Vacations.Bookings do
  @moduledoc """
  GraphQL resolvers for vacation bookings.

  Provides operations for creating and cancelling bookings,
  """

  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Vacations.{Bookings, Booking}
  alias Aquamarine.Accounts.User

  @doc """
  Creates a new booking for the current user.
  """
  @spec create_booking(any(), Booking.create_booking_attr(), %{context: %{current_user: User.t()}}) ::
          {:ok, Booking.t()} | {:error, map()}
  def create_booking(_, params, %{context: %{current_user: user}}) do
    case Bookings.create_booking(user, params) do
      {:ok, booking} -> {:ok, booking}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
      {:error, error} -> {:error, message: inspect(error)}
    end
  end

  @doc """
  Cancels an existing booking for the current user.
  """
  @spec cancel_booking(any(), %{id: Ecto.UUID.t()}, %{context: %{current_user: User.t()}}) ::
          {:ok, Booking.t()} | {:error, map()}
  def cancel_booking(_, %{id: id}, %{context: %{current_user: user}}) do
    with {:ok, booking} <- Bookings.fetch_booking(id),
         {:ok, upd_booking} <- Bookings.cancel_booking(user, booking) do
      {:ok, upd_booking}
    else
      {:error, :not_found} -> record_not_found_error()
      {:error, :unauthorized} -> unauthorized_error()
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
      {:error, error} -> {:error, message: inspect(error)}
    end
  end
end
