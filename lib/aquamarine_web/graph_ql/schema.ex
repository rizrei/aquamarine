defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQL.Schema.BookingTypes)
  import_types(AquamarineWeb.GraphQl.Schema.ReviewTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    import_fields(:place_queries)
  end

  def context(ctx) do
    source = Dataloader.Ecto.new(Aquamarine.Repo)

    loader =
      Dataloader.new()
      |> Dataloader.add_source(Aquamarine.Vacations, source)

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
