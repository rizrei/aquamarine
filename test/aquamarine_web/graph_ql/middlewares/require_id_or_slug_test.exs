defmodule AquamarineWeb.GraphQl.Middlewares.RequireIdOrSlugTest do
  use ExUnit.Case, async: true

  alias AquamarineWeb.GraphQl.Middlewares.RequireIdOrSlug
  alias Absinthe.Resolution

  describe "call/2" do
    test "returns error when both id and slug are provided" do
      res =
        %Resolution{arguments: %{id: "1", slug: "test"}}
        |> RequireIdOrSlug.call(%{})

      assert :resolved = res.state
      assert [[message: "You must provide either `id` or `slug`"]] = res.errors
    end

    test "passes through when id is provided" do
      res =
        %Resolution{arguments: %{id: "1"}}
        |> RequireIdOrSlug.call(%{})

      assert res.state == :unresolved
    end

    test "passes through when slug is provided" do
      res =
        %Resolution{arguments: %{slug: "test"}}
        |> RequireIdOrSlug.call(%{})

      assert res.state == :unresolved
    end

    test "returns error when neither id nor slug is provided" do
      res =
        %Resolution{arguments: %{}}
        |> RequireIdOrSlug.call(%{})

      assert :resolved = res.state
      assert [[message: "You must provide either `id` or `slug`"]] = res.errors
    end
  end
end
