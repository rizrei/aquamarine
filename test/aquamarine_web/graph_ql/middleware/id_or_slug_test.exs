defmodule AquamarineWeb.GraphQL.Middleware.IdOrSlugTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias AquamarineWeb.GraphQL.Middleware.IdOrSlug
  alias Absinthe.Resolution

  describe "call/2" do
    test "returns error when both id and slug are provided" do
      res =
        %Resolution{arguments: %{id: "1", slug: "test"}}
        |> IdOrSlug.call(%{})

      assert :resolved = res.state
      assert [[message: "You must provide either `id` or `slug`"]] = res.errors
    end

    test "passes through when id is provided" do
      res =
        %Resolution{arguments: %{id: "1"}}
        |> IdOrSlug.call(%{})

      assert res.state == :unresolved
    end

    test "passes through when slug is provided" do
      res =
        %Resolution{arguments: %{slug: "test"}}
        |> IdOrSlug.call(%{})

      assert res.state == :unresolved
    end

    test "returns error when neither id nor slug is provided" do
      res =
        %Resolution{arguments: %{}}
        |> IdOrSlug.call(%{})

      assert :resolved = res.state
      assert [[message: "You must provide either `id` or `slug`"]] = res.errors
    end
  end
end
