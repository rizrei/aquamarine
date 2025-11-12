defmodule Aquamarine.Vacations.BookingsTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.{Bookings, Booking}

  describe "get_booking/1" do
    test "returns the booking with the given id" do
      %Booking{id: id} = insert(:booking)
      assert %Booking{id: ^id} = Bookings.get_booking(id)
    end

    test "returns nil if booking does not exists" do
      assert nil == Bookings.get_booking(Ecto.UUID.generate())
    end
  end

  describe "fetch_booking/1" do
    test "returns the booking with the given id" do
      %Booking{id: id} = insert(:booking)
      assert {:ok, %Booking{id: ^id}} = Bookings.fetch_booking(id)
    end

    test "returns nil if booking does not exists" do
      assert {:error, :not_found} == Bookings.fetch_booking(Ecto.UUID.generate())
    end
  end

  describe "create_booking/2" do
    test "return created booking" do
      user = insert(:user)
      place = insert(:place)

      valid_attr = %{place_id: place.id, start_date: ~D[2025-11-11], end_date: ~D[2025-12-12]}

      assert {:ok, %Booking{}} = Bookings.create_booking(user, valid_attr)
    end

    test "when invalid place id" do
      user = insert(:user)

      attr = %{
        place_id: Ecto.UUID.generate(),
        start_date: ~D[2025-11-11],
        end_date: ~D[2025-12-12]
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Bookings.create_booking(user, attr)

      assert "Cannot calculate total price: invalid period or place" in errors_on(changeset).total_price
    end

    test "when invalid period" do
      user = insert(:user)
      place = insert(:place)

      attr = %{place_id: place.id, start_date: ~D[2025-12-12], end_date: ~D[2025-01-01]}

      assert {:error, %Ecto.Changeset{} = changeset} = Bookings.create_booking(user, attr)

      assert "cannot be after :end_date" in errors_on(changeset).start_date
    end
  end

  describe "cancel_booking/1" do
    test "returns canceled booking" do
      user = insert(:user)
      booking = insert(:booking, state: :reserved, user: user)

      assert {:ok, %Booking{state: :canceled}} = Bookings.cancel_booking(user, booking)
    end

    test "does not upd record in seconf time" do
      user = insert(:user)
      booking = insert(:booking, state: :reserved, user: user)

      assert {:ok, %Booking{state: :canceled, updated_at: updated_at} = canceled_booking} =
               Bookings.cancel_booking(user, booking)

      assert {:ok, %Booking{state: :canceled, updated_at: ^updated_at}} =
               Bookings.cancel_booking(user, canceled_booking)
    end

    test "unauthorized user" do
      user = insert(:user)
      booking = insert(:booking, state: :reserved)

      assert {:error, :unauthorized} = Bookings.cancel_booking(user, booking)
    end
  end
end
