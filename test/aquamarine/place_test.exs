defmodule Aquamarine.PlaceTest do
  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.Place

  describe "changeset/2" do
    test "required fields to be set" do
      changeset = Place.changeset(%Place{}, %{})

      required_fields =
        [
          :name,
          :slug,
          :description,
          :location,
          :price_per_night,
          :image,
          :image_thumbnail
        ]
        |> Enum.sort()

      assert ^required_fields = changeset_required_fields_error(changeset)
    end

    test "validates name uniqueness" do
      %{name: name} = insert(:place)
      changeset = Place.changeset(%Place{}, params_for(:place, %{name: name}))

      assert "has already been taken" in errors_on(changeset).name
    end

    test "validates slug uniqueness" do
      %{slug: slug} = insert(:place)
      changeset = Place.changeset(%Place{}, params_for(:place, %{slug: slug}))

      assert "has already been taken" in errors_on(changeset).slug
    end
  end
end
