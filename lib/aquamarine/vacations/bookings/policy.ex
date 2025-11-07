defmodule Aquamarine.Vacations.Bookings.Policy do
  @behaviour Bodyguard.Policy

  alias Aquamarine.Vacations.Booking
  alias Aquamarine.Accounts.User

  def authorize(:cancel_booking, %User{id: user_id}, %Booking{user_id: user_id}), do: true
  def authorize(:cancel_booking, _, _), do: false
end
