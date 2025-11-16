defmodule AquamarineWeb.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Aquamarine.Vacations.Bookings.Dataloader, as: BookingsDataloader
  alias Aquamarine.Vacations.Places.Dataloader, as: PlacesDataloader
  alias AquamarineWeb.GraphQL.Middleware

  import_types(Absinthe.Type.Custom)
  import_types(AquamarineWeb.GraphQL.Schema.UserTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SessionTypes)
  import_types(AquamarineWeb.GraphQL.Schema.PlaceTypes)
  import_types(AquamarineWeb.GraphQL.Schema.ReviewTypes)
  import_types(AquamarineWeb.GraphQL.Schema.BookingTypes)
  import_types(AquamarineWeb.GraphQL.Schema.SortingOrderTypes)

  query do
    import_fields(:place_queries)
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:booking_mutations)
    import_fields(:session_mutations)
    import_fields(:review_mutations)
  end

  subscription do
    import_fields(:booking_subscriptions)
  end

  def context(ctx) do
    ctx
    |> Map.put(:loader, build_loader())
  end

  defp build_loader do
    Dataloader.new()
    |> Dataloader.add_source(DL, Dataloader.Ecto.new(Aquamarine.Repo))
    |> Dataloader.add_source(PlacesDL, PlacesDataloader.datasource())
    |> Dataloader.add_source(BookingsDL, BookingsDataloader.datasource())
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  def middleware(middleware, _field, _object) do
    middleware
    |> List.insert_at(-1, Middleware.ErrorHandler)
  end
end
