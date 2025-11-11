defmodule Aquamarine.BookingTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.Booking

  describe "changeset/2" do
    test "required fields to be set" do
      changeset = Booking.changeset(%Booking{}, %{})

      required_fields = [:start_date, :end_date, :place_id] |> Enum.sort()

      assert ^required_fields = changeset_required_fields_error(changeset)
    end

    test "start date cannot be after end date" do
      %{id: place_id} = insert(:place)

      changeset =
        Booking.changeset(%Booking{}, %{
          start_date: ~D[2025-01-01],
          end_date: ~D[2024-01-01],
          place_id: place_id
        })

      assert "cannot be after :end_date" in errors_on(changeset).start_date
    end

    test "period presents" do
      %{id: place_id} = insert(:place)

      changeset =
        Booking.changeset(%Booking{}, %{
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-02-01],
          place_id: place_id
        })

      range = %Postgrex.Range{lower: ~D[2025-01-01], upper: ~D[2025-02-01]}

      assert ^range = changeset.changes.period
    end

    test "when booking already exists" do
      %{place_id: place_id, period: %{lower: lower, upper: upper}} = insert(:booking)

      changeset =
        Booking.changeset(%Booking{}, %{
          start_date: lower |> Date.add(1),
          end_date: upper |> Date.add(1),
          place_id: place_id
        })

      assert "is not available" in errors_on(changeset).period
    end

    test "total_price presents" do
      %{id: place_id, price_per_night: price} = insert(:place)
      %Date.Range{first: first, last: last} = Date.range(~D[2025-01-01], ~D[2025-02-01])

      changeset =
        Booking.changeset(%Booking{}, %{start_date: first, end_date: last, place_id: place_id})

      total_price = Decimal.mult(price, Date.diff(last, first))

      assert ^total_price = changeset.changes.total_price
    end
  end
end
