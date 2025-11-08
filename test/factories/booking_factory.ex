defmodule Aquamarine.Factories.BookingFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def booking_factory do
        %{price_per_night: price} = place = build(:place)
        lower = Faker.Date.backward(10)
        upper = Faker.Date.forward(10)

        %Aquamarine.Vacations.Booking{
          period: %Postgrex.Range{lower: lower, upper: upper},
          state: "reserved",
          total_price: Decimal.mult(price, Date.diff(upper, lower)),
          place: place,
          user: build(:user)
        }
      end
    end
  end
end
