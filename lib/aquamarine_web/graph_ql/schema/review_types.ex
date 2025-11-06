defmodule AquamarineWeb.GraphQl.Schema.ReviewTypes do
  use Absinthe.Schema.Notation

  # alias AquamarineWeb.GraphQl.Resolvers.Vacations
  object :review do
    field :id, non_null(:id)
    field :rating, non_null(:integer)
    field :comment, non_null(:string)
    field :inserted_at, non_null(:naive_datetime)
  end
end
