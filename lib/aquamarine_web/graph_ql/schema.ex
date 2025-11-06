defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias Aquamarine.Vacations
  alias Aquamarine.Accounts
  alias Aquamarine.Vacations.Dataloader, as: VacationsDataloader
  alias Aquamarine.Accounts.Dataloader, as: AccountsDataloader

  import_types(Absinthe.Type.Custom)
  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQL.Schema.BookingTypes)
  import_types(AquamarineWeb.GraphQl.Schema.ReviewTypes)
  import_types(AquamarineWeb.GraphQl.Schema.UserTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    import_fields(:place_queries)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Vacations, VacationsDataloader.datasource())
      |> Dataloader.add_source(Accounts, AccountsDataloader.datasource())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
