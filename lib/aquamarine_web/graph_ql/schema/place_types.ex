defmodule AquamarineWeb.GraphQL.Schema.PlaceTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to Place management.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  import Absinthe.Resolution.RelayHelpers,
    only: [connection_dataloader: 2, connection_dataloader: 3]

  alias AquamarineWeb.GraphQL.Middleware
  alias AquamarineWeb.GraphQL.Resolvers.Vacations.Places

  object :place do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :location, non_null(:string)
    field :slug, non_null(:string)
    field :description, non_null(:string)
    field :max_guests, non_null(:integer)
    field :pet_friendly, non_null(:boolean)
    field :pool, non_null(:boolean)
    field :wifi, non_null(:boolean)
    field :price_per_night, non_null(:decimal)
    field :image, non_null(:string)
    field :image_thumbnail, non_null(:string)

    field :reviews, list_of(:review), resolve: dataloader(DL)

    field :bookings, list_of(:booking) do
      arg(:limit, :integer, default_value: 50)
      arg(:offset, :integer)
      resolve(dataloader(BookingsDL, :bookings, args: %{scope: :place}))
    end

    connection field :reviews_connection, node_type: :review do
      resolve(connection_dataloader(DL, :reviews))
    end

    connection field :bookings_connection, node_type: :booking do
      resolve(connection_dataloader(BookingsDL, :bookings, args: %{scope: :place}))
    end
  end

  connection(node_type: :place)

  object :place_queries do
    @desc "Get a place by id or slug"
    field :place, :place do
      arg(:slug, :string)
      arg(:id, :id)

      middleware(Middleware.IdOrSlug)

      resolve(&Places.place/3)
    end

    @desc "Get a list of places"
    field :places, list_of(:place) do
      arg(:limit, :integer)
      arg(:offset, :integer)
      arg(:order_by, :place_order)
      arg(:filter, :place_filter)

      resolve(&Places.places/3)
    end

    @desc "Get a list of places connection"
    connection field :places_connection, node_type: :place do
      arg(:order_by, :place_order)
      arg(:filter, :place_filter)

      resolve(&Places.places_connection/3)
    end
  end

  @desc "Filters for the list of places"
  input_object :place_filter do
    @desc "Search by name, location, or description"
    field :search, :string

    @desc "Has wifi"
    field :wifi, :boolean

    @desc "Allows pets"
    field :pet_friendly, :boolean

    @desc "Has a pool"
    field :pool, :boolean

    @desc "Number of guests"
    field :guest_count, :integer

    @desc "Available for booking between a start and end date"
    field :available_between, :date_range
  end

  @desc "Place Order"
  input_object :place_order do
    field :name, :sorting_order
    field :max_guests, :sorting_order
  end

  @desc "Start and end dates"
  input_object :date_range do
    field :start_date, non_null(:date)
    field :end_date, non_null(:date)
  end
end
