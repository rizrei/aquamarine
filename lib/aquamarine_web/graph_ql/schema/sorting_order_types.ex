defmodule AquamarineWeb.GraphQL.Schema.SortingOrderTypes do
  use Absinthe.Schema.Notation

  enum :sorting_order do
    value(:asc)
    value(:desc)
  end
end
