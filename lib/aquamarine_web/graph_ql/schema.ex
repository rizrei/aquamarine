defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias Aquamarine.Vacations

  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)

  query do
    @desc "Get a place by slug"
    field :place, :place do
      arg(:slug, non_null(:string))

      resolve(fn _parent, %{slug: slug}, _resolution ->
        {:ok, Vacations.get_place_by_slug!(slug)}
      end)
    end
  end
end
