[![Elixir CI](https://github.com/rizrei/aquamarine/actions/workflows/elixir.yml/badge.svg)](https://github.com/rizrei/aquamarine/actions/workflows/elixir.yml)
# Aquamarine
Aquamarine is a sample Phoenix + Absinthe (GraphQL) application that demonstrates a vacation rental backend:
places, bookings, and reviews with GraphQL API and Ecto.

## Features

- GraphQL API using Absinthe (mounted at `/graphql`) and GraphiQL in dev.
- Ecto-based data models for Places, Bookings and Reviews.
- Authentication and per-user actions (Guarded via Guardian).
- Real-time update mechanism for bookings, implemented using GraphQL Subscriptions over WebSocket connection.
- Relay Node Interface, providing globally unique object identifiers and a unified entry point for fetching any entity by its ID
- Relay Connections for pagination, allowing efficient, cursor-based navigation through lists such as places, bookings, and reviews

## Installation

1. Install Elixir dependencies:

    ```sh
    mix deps.get
    ```

2. Create the database, run all the migrations, and load the sample data:

    ```sh
    mix ecto.setup
    ```

3. Make sure all the tests pass:

    ```sh
    mix test
    ```

4. Fire up the Phoenix endpoint:

    ```sh
    mix phx.server
    ```
    - GraphQL endpoint: POST to `/graphql`
    - GraphiQL (dev only): `/graphiql`

5. Visit [`localhost:4000/graphiql`](http://localhost:4000/graphiql) to explore the GraphQL API using the GraphiQL user interface.

6. Visit [graphql.org](https://graphql.org/learn) to learn more about GraphQL

## Example Queries, Mutations, and Subscriptions

### Relay Node interface
```graphql
query {
  place: node(id: "UGxhY2U6ZmE3Mzk5NjEtMDRjMS00ZWUzLTkwZGUtOTJmYjhkNTBlOGZh") {
		... on Place {
			id
			name
			bookings {
				id
			}
		}
  }
}
```

### Get All Places

```graphql
query {
  places {
    id
    slug
    name
    location
    description
    image
    imageThumbnail
    pricePerNight
    maxGuests
    petFriendly
    pool
    wifi
  }
}
```

### Get Places Filtered by Name, Description, or Location

```graphql
query {
  places(filter: {search: "lake"}) {
    name
    location
    description
  }
}
```

### Get Places Filtered by Guest Count

```graphql
query {
  places(filter: {guestCount: 6}) {
    name
    maxGuests
  }
}
```

### Get Places Filtered by Features

```graphql
query {
  places(filter: {petFriendly: true, pool: false, wifi: true}) {
    name
    petFriendly
    pool
    wifi
  }
}
```

### Get Places Available From a Start Date to an End Date

```graphql
query {
  places(filter: {
    availableBetween: {startDate: "2019-02-01", endDate:"2019-02-10"}
  }) {
    name
    slug
  }
}
```

### Get a Specific Place By Its Id

```graphql
query {
  place(id: "UGxhY2U6ZmE3Mzk5NjEtMDRjMS00ZWUzLTkwZGUtOTJmYjhkNTBlOGZh") {
    id
    name
    slug
  }
}
```

### Get a Specific Place By Its Slug

```graphql
query {
  place(slug: "mountain-chalet") {
    id
    name
    slug
  }
}
```

### Get a Specific Place and Its Bookings

```graphql
query {
  place(slug: "sand-castle") {
    id
    bookings {
      id
      startDate
      endDate
      state
      totalPrice
    }
  }
}
```

### Get a Specific Place and Its Reviews

```graphql
query {
  place(slug: "sand-castle") {
    id
    reviews {
      id
      rating
      comment
      user {
        username
      }
    }
  }
}
```

### Sign Up

```graphql
mutation {
  signUp(name: "MyName", password: "Password", email: "example@mail.com") {
    user{
			id
			name
			email
		}
    accessToken
		refreshToken
  }
}
```

### Sign In

```graphql
mutation {
  signIn(name: "MyName", password: "Password") {
    user{
			id
			name
			email
		}
    accessToken
		refreshToken
  }
}
```

### Sign Out (access_token required)

```graphql
mutation {
  signOut{
		success
	}
}
```

### Refresh token

```graphql
mutation {
  refreshToken(refreshToken: "my_refresh_token") {
    user{
			id
			name
			email
			bookings{
				id
			}
		}
    accessToken
		refreshToken
  }
}
```

### Get the Currently Signed-in User

```graphql
query {
  me {
    name
    email
  }
}
```

### Get the Current User's Bookings

```graphql
query {
  me {
    bookings {
      id
      startDate
      endDate
      state
      totalPrice
    }
  }
}
```

### Create a Booking for the Current User and a Place

```graphql
mutation {
  createBooking(
    placeId: "UGxhY2U6ZmE3Mzk5NjEtMDRjMS00ZWUzLTkwZGUtOTJmYjhkNTBlOGZh",
    startDate: "2019-03-01",
    endDate: "2019-03-05") {
    id
    startDate
    endDate
    state
    totalPrice
  }
}
```

### Cancel a Booking for the Current User

```graphql
mutation {
  cancelBooking(id: "Qm9va2luZzo2YTQ4ODYxOC1kNmFhLTQwYWEtYTAxOS1hMGUxMTk0M2VlMWM=") {
    id
    state
  }
}
```

### Subscribe to Booking Changes for a Specific Place

```graphql
subscription {
  bookingChange(placeId: "UGxhY2U6ZmE3Mzk5NjEtMDRjMS00ZWUzLTkwZGUtOTJmYjhkNTBlOGZh") {
    id
    startDate
    endDate
    totalPrice
    state
  }
}
```

### Create a Review by the Current User for a Specific Place

```graphql
mutation {
  createReview(
    placeId: "UGxhY2U6ZmE3Mzk5NjEtMDRjMS00ZWUzLTkwZGUtOTJmYjhkNTBlOGZh"
    comment: "Love!"
    rating: 5
  ) {
    id
    rating
    comment
    insertedAt
    user {
      name
    }
  }
}
```

### Introspecting the Schema

```graphql
{
  __type(name: "Place") {
    fields {
      name
      type {
        kind
        name
      }
    }
  }
}
```

