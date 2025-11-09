defmodule AquamarineWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias Aquamarine.Dataloader, as: DefaultDataloader
  alias Aquamarine.Accounts.Dataloader, as: AccountsDataloader
  alias Aquamarine.Vacations.Places.Dataloader, as: PlacesDataloader
  alias Aquamarine.Vacations.Bookings.Dataloader, as: BookingsDataloader

  import_types(Absinthe.Type.Custom)
  import_types(AquamarineWeb.GraphQl.Schema.UserTypes)
  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQl.Schema.ReviewTypes)
  import_types(AquamarineWeb.GraphQL.Schema.BookingTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    import_fields(:place_queries)
  end

  mutation do
    import_fields(:booking_mutations)
  end

  def context(ctx) do
    ctx
    |> Map.put(:loader, build_loader())
    |> Map.put(:current_user, Aquamarine.Accounts.get_user_by_email("alice@mail.com"))
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  defp build_loader do
    Dataloader.new()
    |> Dataloader.add_source(DefaultLoader, DefaultDataloader.datasource())
    |> Dataloader.add_source(Places, PlacesDataloader.datasource())
    |> Dataloader.add_source(Bookings, BookingsDataloader.datasource())
    |> Dataloader.add_source(Accounts, AccountsDataloader.datasource())
  end
end
