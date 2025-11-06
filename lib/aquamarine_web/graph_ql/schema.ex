defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias AquamarineWeb.GraphQl.Resolvers.Vacations

  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    @desc "Get a place by id or slug"
    field :place, :place do
      arg(:slug, :string)
      arg(:id, :id)

      resolve(&Vacations.place/3)
    end

    @desc "Get a list of places"
    field :places, list_of(:place) do
      arg(:limit, :integer)
      arg(:order_by, :place_order)
      arg(:filter, :place_filter)

      resolve(&Vacations.places/3)
    end
  end
end
