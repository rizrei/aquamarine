defmodule Aquamarine.Vacations.Bookings do
  @moduledoc """
  Context module for managing vacation bookings.

  Provides functions to get, create, and cancel bookings,
  """

  import Absinthe.Relay.Node, only: [from_global_id: 2]

  alias __MODULE__.Policy
  alias Aquamarine.Accounts.User
  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Booking
  alias AquamarineWeb.GraphQL.Schema

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
          {:ok, Booking.t()} | {:error, Ecto.Changeset.t()} | {:error, String.t()}
  def create_booking(%User{} = user, %{} = params) do
    with {:ok, place_gid} <- Map.fetch(params, :place_id),
         {:ok, %{id: place_id, type: :place}} <- from_global_id(place_gid, Schema) do
      %Booking{}
      |> Booking.changeset(%{params | place_id: place_id})
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Aquamarine.Repo.insert()
    else
      :error -> {:error, "Invalid place_id"}
      error -> error
    end
  end

  def create_booking(_, _), do: {:error, "Invalid input params"}

  @doc """
  Cancels the given booking.
  """
  @spec cancel_booking(User.t(), %{id: String.t()}) ::
          {:ok, Booking.t()} | {:error, Ecto.Changeset.t()} | {:error, atom()}
  def cancel_booking(%User{} = user, %{id: gid}) do
    with {:ok, %{id: id, type: :booking}} <- from_global_id(gid, Schema),
         {:ok, booking} <- fetch_booking(id),
         :ok <- Bodyguard.permit(Policy, :cancel_booking, user, booking) do
      booking
      |> Booking.cancel_changeset()
      |> Repo.update()
    end
  end

  def cancel_booking(_, _), do: {:error, "Invalid input params"}
end
