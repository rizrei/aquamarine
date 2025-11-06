defmodule AquamarineWeb.GraphQL.Schema.BookingTypes do
  use Absinthe.Schema.Notation

  # alias AquamarineWeb.GraphQl.Resolvers.Vacations

  object :booking do
    field :id, non_null(:id)
    field :state, non_null(:string)
    field :start_date, non_null(:date), resolve: &resolve_start_date/3
    field :end_date, non_null(:date), resolve: &resolve_end_date/3
    field :total_price, non_null(:decimal)
  end

  def resolve_start_date(%{period: %Postgrex.Range{lower: lower}}, _, _), do: {:ok, lower}
  def resolve_end_date(%{period: %Postgrex.Range{upper: upper}}, _, _), do: {:ok, upper}
end
