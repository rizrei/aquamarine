defmodule AquamarineWeb.GraphQL.Schema.NodeTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to Review management.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias AquamarineWeb.GraphQl.Resolvers.Node

  object :node_queries do
    @desc "Node query"
    node field do
      resolve(&Node.node/2)
    end
  end
end
