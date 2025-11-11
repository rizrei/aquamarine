defmodule Aquamarine.ReviewTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.Review

  describe "changeset/2" do
    test "required fields to be set" do
      changeset = Review.changeset(%Review{}, %{})

      required_fields = [:rating, :comment, :place_id] |> Enum.sort()

      assert ^required_fields = changeset_required_fields_error(changeset)
    end
  end
end
