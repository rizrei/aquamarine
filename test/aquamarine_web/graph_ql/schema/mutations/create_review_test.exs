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
    %{id: place_id} = insert(:place)

    variables = %{placeId: place_id, rating: 5, comment: "Comment"}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"data" => %{"createReview" => review}} = json_response(conn, 200)

    assert %{"id" => _, "place" => %{"id" => ^place_id}} = review
    assert variables.comment == review["comment"]
    assert variables.rating == review["rating"]
  end

  test "return changeset error when invalid params", %{conn: conn} do
    user = insert(:user)

    variables = %{placeId: Ecto.UUID.generate(), rating: 5, comment: "Comment"}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Invalid input params" in graphql_error_messages(errors)
    assert %{"place" => ["does not exist"]} in graphql_error_details(errors)
  end

  test "return authentication_required error when unauthenticated", %{conn: conn} do
    variables = %{placeId: Ecto.UUID.generate(), rating: 5, comment: "Comment"}

    conn = graphql_query(conn, @mutation, variables)

    assert %{"errors" => errors} = json_response(conn, 200)
    assert "Authentication required" in graphql_error_messages(errors)
  end
end
