defmodule AquamarineWeb.GraphQl.Schema.ReviewTypes do
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  # alias AquamarineWeb.GraphQl.Resolvers.Vacations
  object :review do
    field :id, non_null(:id)
    field :rating, non_null(:integer)
    field :comment, non_null(:string)
    field :inserted_at, non_null(:naive_datetime)

    field :user, non_null(:user), resolve: dataloader(Aquamarine.Vacations)
    field :place, non_null(:place), resolve: dataloader(Aquamarine.Vacations)
  end
end
