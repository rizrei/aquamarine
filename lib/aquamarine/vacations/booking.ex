defmodule Aquamarine.Vacations.Booking do
  @moduledoc """
  Schema and changeset for bookings made by users for vacation places.

  A `Booking` represents a reservation of a specific `Place` by a `User`
  for a given date range. It includes the booking state, total price,
  and integrity checks ensuring that periods do not overlap and are valid.

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Aquamarine.Vacations.Bookings.Validations

  alias Aquamarine.Accounts.User
  alias Aquamarine.Vacations.Place

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          period: Date.Range.t() | Postgrex.Range.t() | nil,
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          state: :reserved | :canceled,
          total_price: Decimal.t() | nil,
          place_id: Ecto.UUID.t() | nil,
          place: Place.t() | Ecto.Association.NotLoaded.t(),
          user_id: Ecto.UUID.t() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @type create_booking_attr :: %{
          start_date: Date.t(),
          end_date: Date.t(),
          place_id: Ecto.UUID.t()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :period, EctoRange.Date
    field :start_date, :date, virtual: true
    field :end_date, :date, virtual: true
    field :state, Ecto.Enum, values: [:reserved, :canceled], default: :reserved
    field :total_price, :decimal

    belongs_to :place, Place
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(booking, attrs) do
    required_fields = [:start_date, :end_date, :place_id]
    optional_fields = [:state]

    booking
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> validate_dates()
    |> put_period()
    |> validate_period_available()
    |> assoc_constraint(:place)
    |> assoc_constraint(:user)
    |> put_total_price()
  end

  def cancel_changeset(booking) do
    booking
    |> change()
    |> put_change(:state, :canceled)
  end
end
