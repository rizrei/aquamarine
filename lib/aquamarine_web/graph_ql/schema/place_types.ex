defmodule AquamarineWeb.GraphQL.Schema.PlaceTypes do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  alias AquamarineWeb.GraphQL.Resolvers.Vacations.Places
  alias AquamarineWeb.GraphQL.Middlewares

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

    field :bookings, list_of(:booking) do
      arg(:limit, :integer, default_value: 100)
      resolve(dataloader(Bookings, :bookings, args: %{scope: :place}))
    end

    field :reviews, list_of(:review), resolve: dataloader(Reviews)
  end

  object :place_queries do
    @desc "Get a place by id or slug"
    field :place, :place do
      arg(:slug, :string)
      arg(:id, :id)

      middleware(Middlewares.IdOrSlug)

      resolve(&Places.place/3)
    end

    @desc "Get a list of places"
    field :places, list_of(:place) do
      arg(:limit, :integer)
      arg(:order_by, :place_order)
      arg(:filter, :place_filter)

      resolve(&Places.places/3)
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
