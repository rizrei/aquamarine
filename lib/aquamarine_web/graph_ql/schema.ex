defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    import_fields(:place_queries)
  end
end
