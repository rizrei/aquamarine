defmodule AquamarineWeb.GraphQL.Schema.UserTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to User management.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [dataloader: 1, dataloader: 3]

  import Absinthe.Resolution.RelayHelpers,
    only: [connection_dataloader: 2, connection_dataloader: 3]

  alias AquamarineWeb.GraphQl.Resolvers.Accounts.Users

  node object(:user) do
    field :name, non_null(:string)
    field :email, non_null(:string)

    field :reviews, list_of(:review), resolve: dataloader(DL)

    field :bookings, list_of(:booking) do
      arg(:limit, :integer)
      arg(:offset, :integer)

      resolve(dataloader(BookingsDL, :bookings, args: %{scope: :user}))
    end

    connection field :reviews_connection, node_type: :review do
      resolve(connection_dataloader(DL, :reviews))
    end

    connection field :bookings_connection, node_type: :booking do
      resolve(connection_dataloader(BookingsDL, :bookings, args: %{scope: :user}))
    end
  end

  object :user_queries do
    @desc "Get the currently signed in user"
    field :me, :user do
      resolve(&Users.me/3)
    end
  end
end
