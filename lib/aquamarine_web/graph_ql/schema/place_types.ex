defmodule AquamarineWeb.GraphQL.Schema.PlaceTypes do
  use Absinthe.Schema.Notation
  import_types(Absinthe.Type.Custom)

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
