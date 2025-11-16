defmodule Aquamarine.Vacations.BookingsTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.{Booking, Bookings}

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
      place_gid = insert(:place) |> to_global_id(:place)

      attr = %{place_id: place_gid, start_date: ~D[2025-11-11], end_date: ~D[2025-12-12]}

      assert {:ok, %Booking{}} = Bookings.create_booking(user, attr)
    end

    test "when invalid user param" do
      user = %{id: Ecto.UUID.generate(), email: "testemail@mail.com"}
      place_gid = %{id: Ecto.UUID.generate()} |> to_global_id(:place)

      attr = %{place_id: place_gid, start_date: ~D[2025-11-11], end_date: ~D[2025-12-12]}

      assert {:error, "Invalid input params"} = Bookings.create_booking(user, attr)
    end

    test "when invalid place id" do
      user = insert(:user)
      place_gid = %{id: Ecto.UUID.generate()} |> to_global_id(:place)

      attr = %{place_id: place_gid, start_date: ~D[2025-11-11], end_date: ~D[2025-12-12]}

      assert {:error, %Ecto.Changeset{} = changeset} = Bookings.create_booking(user, attr)
      assert "place not found" in errors_on(changeset).place_id
    end

    test "when invalid period" do
      user = insert(:user)
      place_gid = insert(:place) |> to_global_id(:place)

      attr = %{place_id: place_gid, start_date: ~D[2025-12-12], end_date: ~D[2025-01-01]}

      assert {:error, %Ecto.Changeset{} = changeset} = Bookings.create_booking(user, attr)
      assert "cannot be after :end_date" in errors_on(changeset).start_date
    end

    test "when place_id is internal place_id" do
      user = insert(:user)
      %{id: place_id} = insert(:user)

      attr = %{place_id: place_id, start_date: ~D[2025-11-11], end_date: ~D[2025-12-12]}
      message = "Could not decode ID value `#{place_id}'"
      assert {:error, ^message} = Bookings.create_booking(user, attr)
    end
  end

  describe "cancel_booking/1" do
    test "returns canceled booking" do
      user = insert(:user)
      booking_gid = insert(:booking, state: :reserved, user: user) |> to_global_id(:booking)

      assert {:ok, %Booking{state: :canceled}} = Bookings.cancel_booking(user, %{id: booking_gid})
    end

    test "does not upd record in seconf time" do
      user = insert(:user)
      booking_gid = insert(:booking, state: :reserved, user: user) |> to_global_id(:booking)

      assert {:ok, %Booking{state: :canceled, updated_at: updated_at}} =
               Bookings.cancel_booking(user, %{id: booking_gid})

      assert {:ok, %Booking{state: :canceled, updated_at: ^updated_at}} =
               Bookings.cancel_booking(user, %{id: booking_gid})
    end

    test "when booking_id is internal booking_id" do
      user = insert(:user)
      booking = insert(:booking, state: :reserved, user: user)

      message = "Could not decode ID value `#{booking.id}'"
      assert {:error, ^message} = Bookings.cancel_booking(user, %{id: booking.id})
    end

    test "unauthorized user" do
      user = insert(:user)
      booking_gid = insert(:booking, state: :reserved) |> to_global_id(:booking)

      assert {:error, :unauthorized} = Bookings.cancel_booking(user, %{id: booking_gid})
    end
  end
end
