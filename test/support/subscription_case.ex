# credo:disable-for-this-file Credo.Check.Design.AliasUsage

defmodule AquamarineWeb.SubscriptionCase do
  @moduledoc """
  This module defines the test case to be used by
  subscription tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Absinthe.Phoenix.SubscriptionTest, schema: AquamarineWeb.GraphQL.Schema
      use AquamarineWeb.ConnCase

      import Phoenix.ChannelTest

      setup tags do
        {:ok, socket} = Phoenix.ChannelTest.connect(AquamarineWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

        {:ok, socket: socket}
      end
    end
  end
end
