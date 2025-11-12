defmodule Aquamarine.Vacations.ReviewsTest do
  @moduledoc false

  use Aquamarine.DataCase, async: true

  alias Aquamarine.Vacations.{Reviews, Review}

  describe "get_review/1" do
    test "returns the Review with the given id" do
      %Review{id: id} = insert(:review)
      assert %Review{id: ^id} = Reviews.get_review(id)
    end

    test "returns nil if Review does not exists" do
      assert nil == Reviews.get_review(Ecto.UUID.generate())
    end
  end

  describe "create_review/2" do
    test "return created review" do
      user = insert(:user)
      place = insert(:place)

      attr = %{place_id: place.id, rating: 5, comment: "Comment"}

      assert {:ok, %Review{}} = Reviews.create_review(user, attr)
    end

    test "when invalid place id" do
      user = insert(:user)

      attr = %{place_id: Ecto.UUID.generate(), rating: 5, comment: "Comment"}

      assert {:error, %Ecto.Changeset{} = changeset} = Reviews.create_review(user, attr)

      assert "does not exist" in errors_on(changeset).place
    end
  end
end
