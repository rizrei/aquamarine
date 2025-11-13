defmodule Aquamarine.Vacations.Place do
  @moduledoc """
  Schema and changeset for vacation places available for booking.

  A `Place` represents a rental property or vacation destination listed in the system.
  It includes descriptive information, pricing, amenities, and relations to associated
  bookings and reviews.

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Aquamarine.Repo
  alias Aquamarine.Vacations.{Booking, Review}

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          name: String.t() | nil,
          slug: String.t() | nil,
          description: String.t() | nil,
          location: String.t() | nil,
          price_per_night: Decimal.t() | nil,
          image: String.t() | nil,
          image_thumbnail: String.t() | nil,
          max_guests: integer(),
          pet_friendly: boolean(),
          pool: boolean(),
          wifi: boolean(),
          bookings: [Booking.t()] | Ecto.Association.NotLoaded.t(),
          reviews: [Review.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "places" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :location, :string
    field :price_per_night, :decimal
    field :image, :string
    field :image_thumbnail, :string
    field :max_guests, :integer, default: 2
    field :pet_friendly, :boolean, default: false
    field :pool, :boolean, default: false
    field :wifi, :boolean, default: false

    has_many :bookings, Booking
    has_many :reviews, Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(place, attrs) do
    required_fields = [
      :name,
      :slug,
      :description,
      :location,
      :price_per_night,
      :image,
      :image_thumbnail
    ]

    optional_fields = [:max_guests, :pet_friendly, :pool, :wifi]

    place
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> unsafe_validate_unique(:name, Repo)
    |> unsafe_validate_unique(:slug, Repo)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
