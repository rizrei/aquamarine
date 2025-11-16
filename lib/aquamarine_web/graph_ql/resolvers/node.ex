defmodule AquamarineWeb.GraphQl.Resolvers.Node do
  @moduledoc """
  Resolver for handling the Relay Node interface.

  This module provides two main responsibilities required by the Relay Node
  specification:

  ### 1. `resolve_type/2` for the Node interface
  It determines the concrete GraphQL type for a returned struct.
  Based on the struct's module, it maps Ecto schemas (`User`, `Place`, `Booking`,
  `Review`) to the corresponding GraphQL object types (`:user`, `:place`,
  `:booking`, `:review`).

  ### 2. `node/2` for resolving Relay global IDs
  Given a decoded global ID (`type` and `id`), it fetches the corresponding
  record from the database.
  If the type is unknown or the record does not exist, an error tuple is returned.

  ## Relay Flow

  - Incoming Global ID → `from_global_id/2` → `%{type: :place, id: "..."}`
  - Absinthe calls `node/2` to load the resource.
  - Absinthe calls `resolve_type/2` to map the loaded struct to its GraphQL type.

  ## Return values

    * `{:ok, struct}` — when a record is successfully fetched.
    * `{:error, :not_found}` — when the record does not exist or the type is invalid.

  This resolver is used internally by the `node interface` in the GraphQL schema
  and supports all Relay Node lookups in the API.
  """

  alias Aquamarine.Accounts.User
  alias Aquamarine.Vacations.{Booking, Place, Review}

  def node_type(%User{}, _resolution), do: :user
  def node_type(%Place{}, _resolution), do: :place
  def node_type(%Booking{}, _resolution), do: :booking
  def node_type(%Review{}, _resolution), do: :review
  def node_type(_, _), do: nil

  def node(%{type: :place, id: id}, _res), do: fetch_record(Place, id)
  def node(%{type: :booking, id: id}, _res), do: fetch_record(Booking, id)
  def node(%{type: :review, id: id}, _res), do: fetch_record(Review, id)
  def node(%{type: :user, id: id}, _res), do: fetch_record(User, id)
  def node(_, _), do: {:error, :not_found}

  defp fetch_record(schema_type, id) do
    case Aquamarine.Repo.get(schema_type, id) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
