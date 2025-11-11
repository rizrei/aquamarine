defmodule AquamarineWeb.GraphQl.Middlewares.AuthenticateTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias AquamarineWeb.GraphQL.Middlewares.Authenticate
  alias Absinthe.Resolution

  describe "call/2" do
    test "returns error when user does not present" do
      res =
        %Resolution{context: %{}}
        |> Authenticate.call(%{})

      assert :resolved = res.state
      assert [[message: "Authentication required"]] = res.errors
    end

    test "passes through when user is provided" do
      res =
        %Resolution{context: %{current_user: build(:user)}}
        |> Authenticate.call(%{})

      assert res.state == :unresolved
    end
  end
end
