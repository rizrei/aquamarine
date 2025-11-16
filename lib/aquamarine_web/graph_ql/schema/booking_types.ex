defmodule AquamarineWeb.GraphQL.Schema.BookingTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to Booking management.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias AquamarineWeb.GraphQL.Middleware
  alias AquamarineWeb.GraphQL.Resolvers.Vacations.Bookings

  object :booking do
    field :id, non_null(:id)
    field :state, non_null(:string)
    field :start_date, non_null(:date), resolve: &resolve_start_date/3
    field :end_date, non_null(:date), resolve: &resolve_end_date/3
    field :total_price, non_null(:decimal)

    field :user, non_null(:user), resolve: dataloader(DL)
    field :place, non_null(:place), resolve: dataloader(DL)
  end

  connection(node_type: :booking)

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

      config(fn %{place_id: place_id}, _res -> {:ok, topic: place_id} end)

      trigger([:create_booking, :cancel_booking], topic: & &1.place_id)
    end
  end

  def resolve_start_date(%{period: %Postgrex.Range{lower: lower}}, _, _), do: {:ok, lower}
  def resolve_end_date(%{period: %Postgrex.Range{upper: upper}}, _, _), do: {:ok, upper}
end
