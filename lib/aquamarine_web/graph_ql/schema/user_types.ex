defmodule AquamarineWeb.GraphQL.Schema.UserTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to User management.
  """

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  object :user do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :email, non_null(:string)

    field :bookings, list_of(:booking),
      resolve: dataloader(Bookings, :bookings, args: %{scope: :user})

    field :reviews, list_of(:review), resolve: dataloader(DefaultLoader)
  end
end
