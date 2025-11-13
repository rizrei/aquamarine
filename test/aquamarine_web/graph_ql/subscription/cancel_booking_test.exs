defmodule AquamarineWeb.Schema.Subscription.CancelBookingTest do
  @moduledoc false

  use AquamarineWeb.SubscriptionCase, async: false

  @mutation """
  mutation ($id: ID!) {
    cancelBooking(id: $id) {
      id
    }
  }
  """

  @subscription """
    subscription ($placeId: ID!) {
      bookingChange(placeId: $placeId) {
        id
      }
    }
  """

  test "canceled booking can be subscribed to", %{socket: socket, conn: conn} do
    user = insert(:user)
    place = insert(:place)
    %{id: booking_id} = insert(:booking, user: user, place: place)

    #
    # 1. Setup the subscription
    #
    ref = push_doc(socket, @subscription, variables: %{placeId: place.id})
    assert_reply ref, :ok, %{subscriptionId: subscription_id}

    #
    # 2. Run a mutation to trigger the subscription
    #
    conn =
      conn
      |> authenticate(user)
      |> graphql_query(@mutation, %{id: booking_id})

    assert %{"data" => %{"cancelBooking" => %{"id" => ^booking_id}}} = json_response(conn, 200)

    #
    # 3. Assert that the expected subscription data was pushed to us
    #
    assert_push "subscription:data", payload
    assert %{result: result, subscriptionId: ^subscription_id} = payload
    assert %{data: %{"bookingChange" => %{"id" => ^booking_id}}} = result
  end
end
