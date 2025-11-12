defmodule Aquamarine.Vacations.PlacesTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.Places

  def places_available_between(start_date, end_date) do
    Places.list_places(%{
      filter: %{available_between: %{start_date: start_date, end_date: end_date}}
    })
  end

  describe "get_place_by_slug/1" do
    test "returns the place with the given slug" do
      place = insert(:place)
      assert ^place = Places.get_place_by_slug(place.slug)
    end

    test "returns nil if place does not exists" do
      assert nil == Places.get_place_by_slug("slug")
    end
  end

  describe "get_place/1" do
    test "returns the place with the given id" do
      place = insert(:place)
      assert ^place = Places.get_place(place.id)
    end

    test "returns nil if place does not exists" do
      assert nil == Places.get_place(Ecto.UUID.generate())
    end
  end

  describe "list_places/1" do
    test "when limit is 0" do
      {:error, changeset} = Places.list_places(%{limit: 0})

      assert "must be greater than or equal to 1" in errors_on(changeset).limit
    end

    test "when start_date greater then end_date" do
      {:error, changeset} = places_available_between(~D[2026-01-01], ~D[2025-01-01])

      assert "cannot be after :end_date" in errors_on(changeset).filter.available_between.start_date
    end

    test "when search term to short" do
      {:error, changeset} = Places.list_places(%{filter: %{search: "1"}})

      assert "should be at least 2 character(s)" in errors_on(changeset).filter.search
    end

    test "when guest_count is 0" do
      {:error, changeset} = Places.list_places(%{filter: %{guest_count: 0}})

      assert "must be greater than 0" in errors_on(changeset).filter.guest_count
    end

    test "when invalid order_by" do
      {:error, changeset} = Places.list_places(%{order_by: %{name: :foo}})

      assert "is invalid" in errors_on(changeset).order_by.name
    end

    test "returns all places by default" do
      place = insert(:place)

      assert [^place] = Places.list_places(%{})
    end

    test "returns limited number of places" do
      place = insert(:place)

      assert [^place] = Places.list_places(%{limit: 1})
    end

    test "returns limited and ordered places" do
      ["Place 3", "Place 1", "Place 2"] |> Enum.each(fn name -> insert(:place, name: name) end)

      results = Places.list_places(%{limit: 3, order_by: %{name: :desc}})

      assert Enum.map(results, & &1.name) == ["Place 3", "Place 2", "Place 1"]
    end

    test "returns places filtered by matching name" do
      place = insert(:place, name: "FooBar")
      insert(:place, name: "BarBaz")

      assert [^place] = Places.list_places(%{filter: %{search: "Foo"}})
    end

    test "returns places filtered by pet friendly" do
      place = insert(:place, pet_friendly: true)
      insert(:place, pet_friendly: false)

      assert [^place] = Places.list_places(%{filter: %{pet_friendly: true}})
    end

    test "returns places filtered by pool" do
      place = insert(:place, pool: true)
      insert(:place, pool: false)

      assert [^place] = Places.list_places(%{filter: %{pool: true}})
    end

    test "returns places filtered by wifi" do
      place = insert(:place, wifi: true)
      insert(:place, wifi: false)

      assert [^place] = Places.list_places(%{filter: %{wifi: true}})
    end

    test "returns places filtered by guest count" do
      place = insert(:place, max_guests: 3)
      insert(:place, max_guests: 2)

      assert [^place] = Places.list_places(%{filter: %{guest_count: 3}})
    end

    test "returns places available between dates" do
      place = insert(:place)

      insert(:booking,
        place: place,
        period: %Postgrex.Range{lower: ~D[2025-01-05], upper: ~D[2025-01-10]}
      )

      # Existing booking period:
      #        01-05    01-10
      # --------[---------]-------

      # Case 1
      # --------[---------]-------
      assert [] = places_available_between(~D[2025-01-05], ~D[2025-01-10])

      # Case 2
      # --------[----]------------
      assert [] = places_available_between(~D[2025-01-05], ~D[2025-01-08])

      # Case 3
      # -------------[----]-------
      assert [] = places_available_between(~D[2025-01-08], ~D[2025-01-10])

      # Case 4
      # [-----]-------------------
      assert [^place] = places_available_between(~D[2025-01-01], ~D[2025-01-04])

      # Case 5
      # --------------------[----]
      assert [^place] = places_available_between(~D[2025-01-11], ~D[2025-01-12])

      # Case 6
      # -----[----]---------------
      assert [] = places_available_between(~D[2025-01-04], ~D[2025-01-05])

      # Case 7
      # -----------[---]----------
      assert [] = places_available_between(~D[2025-01-07], ~D[2025-01-08])

      # Case 8
      # ------[-------]-----------
      assert [] = places_available_between(~D[2025-01-04], ~D[2025-01-08])

      # Case 9
      # --------------[--------]--
      assert [] = places_available_between(~D[2025-01-08], ~D[2025-01-12])

      # Case 10
      # -----[----------------]---
      assert [] = places_available_between(~D[2025-01-03], ~D[2025-01-12])
    end
  end
end
