defmodule AquamarineWeb.GraphQL.Schema.BookingTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to Booking management.
  """

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias AquamarineWeb.GraphQL.Resolvers.Vacations.Bookings
  alias AquamarineWeb.GraphQL.Middleware

  object :booking do
    field :id, non_null(:id)
    field :state, non_null(:string)
    field :start_date, non_null(:date), resolve: &resolve_start_date/3
    field :end_date, non_null(:date), resolve: &resolve_end_date/3
    field :total_price, non_null(:decimal)

    field :user, non_null(:user), resolve: dataloader(Accounts)
    field :place, non_null(:place), resolve: dataloader(Places)
  end

  object :booking_mutations do
    @desc "Create booking for place"
    field :create_booking, :booking do
      arg(:place_id, non_null(:id))
      arg(:start_date, non_null(:date))
      arg(:end_date, non_null(:date))

      middleware(Middleware.Authenticate)

      resolve(&Bookings.create_booking/3)
    end

    @desc "Cancel booking by id"
    field :cancel_booking, :booking do
      arg(:id, non_null(:id))

      middleware(Middleware.Authenticate)

      resolve(&Bookings.cancel_booking/3)
    end
  end

  object :booking_subscriptions do
    @desc "Subscribe to booking changes for a place"
    field :booking_change, :booking do
      arg(:place_id, non_null(:id))

      config(fn args, _res -> {:ok, topic: args.place_id} end)

      trigger([:create_booking, :cancel_booking], topic: fn booking -> booking.place_id end)
    end
  end

  def resolve_start_date(%{period: %Postgrex.Range{lower: lower}}, _, _), do: {:ok, lower}
  def resolve_end_date(%{period: %Postgrex.Range{upper: upper}}, _, _), do: {:ok, upper}
end
