defmodule AquamarineWeb.GraphQl.Resolvers.Vacations.Bookings do
  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Vacations.Bookings
  alias Aquamarine.Vacations.Booking

  def create_booking(_, params, %{context: %{current_user: user}}) do
    case Bookings.create_booking(user, params) do
      {:ok, booking} -> {:ok, booking}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
    end
  end

  def cancel_booking(_, params, %{context: %{current_user: user}}) do
    with {:ok, booking} <- get_booking(params),
         {:ok, upd_booking} <- Bookings.cancel_booking(user, booking) do
      {:ok, upd_booking}
    else
      {:error, :not_found} -> record_not_found_error()
      {:error, :unauthorized} -> unauthorized_error()
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
    end
  end

  defp get_booking(%{booking_id: id}) do
    case Bookings.get_booking(id) do
      %Booking{} = booking -> {:ok, booking}
      _ -> {:error, :not_found}
    end
  end

  defp get_booking(_), do: {:error, :not_found}
end
