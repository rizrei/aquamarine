defmodule AquamarineWeb.Schema.Subscription.CreateBookingTest do
  use AquamarineWeb.SubscriptionCase, async: false

  @mutation """
  mutation ($placeId: ID!, $startDate: Date!, $endDate: Date!) {
    createBooking(placeId: $placeId, startDate: $startDate, endDate: $endDate) {
      startDate
      endDate
    }
  }
  """

  @subscription """
    subscription ($placeId: ID!) {
      bookingChange(placeId: $placeId) {
        startDate
        endDate
      }
    }
  """
  test "new booking can be subscribed to", %{socket: socket, conn: conn} do
    user = insert(:user)
    place_gid = insert(:place) |> to_global_id(:place)

    #
    # 1. Setup the subscription
    #
    ref = push_doc(socket, @subscription, variables: %{placeId: place_gid})
    assert_reply ref, :ok, %{subscriptionId: subscription_id}

    #
    # 2. Run a mutation to trigger the subscription
    #
    variables = %{"startDate" => "2025-11-11", "endDate" => "2025-11-22", "placeId" => place_gid}

    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, variables)

    assert %{"data" => %{"createBooking" => booking}} = json_response(conn, 200)
    assert %{"startDate" => "2025-11-11", "endDate" => "2025-11-22"} = booking

    #
    # 3. Assert that the expected subscription data was pushed to us
    #
    assert_push "subscription:data", payload
    assert %{result: result, subscriptionId: ^subscription_id} = payload
    assert %{data: %{"bookingChange" => booking}} = result
    assert %{"startDate" => "2025-11-11", "endDate" => "2025-11-22"} = booking
  end
end
