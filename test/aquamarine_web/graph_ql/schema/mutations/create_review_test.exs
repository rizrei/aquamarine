defmodule AquamarineWeb.GraphQL.Schema.Mutations.CreateReviewTest do
  @moduledoc false

  use AquamarineWeb.ConnCase, async: true

  @mutation """
  mutation($placeId: ID!, $rating: Int!, $comment: String!) {
    createReview(placeId: $placeId, rating: $rating, comment: $comment) {
      id
      rating
      comment
      place {
        id
      }
    }
  }
  """
  test "create review when params valid", %{conn: conn} do
    user = insert(:user)
    place_gid = insert(:place) |> to_global_id(:place)

    variables = %{placeId: place_gid, rating: 5, comment: "Comment"}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"data" => %{"createReview" => review}} = json_response(conn, 200)

    assert %{"id" => _, "place" => %{"id" => ^place_gid}} = review
    assert variables.comment == review["comment"]
    assert variables.rating == review["rating"]
  end

  test "return changeset error when invalid params", %{conn: conn} do
    user = insert(:user)
    place_gid = insert(:place) |> to_global_id(:place)

    variables = %{placeId: place_gid, rating: 150, comment: ""}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    details = %{"comment" => ["can't be blank"], "rating" => ["must be less than or equal to 5"]}
    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid input params" in graphql_error_messages(errors)
    assert details in graphql_error_details(errors)
  end

  test "return authentication_required error when unauthenticated", %{conn: conn} do
    variables = %{placeId: Ecto.UUID.generate(), rating: 5, comment: "Comment"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end
end
