defmodule Aquamarine.Vacations.Booking do
  use Ecto.Schema

  import Ecto.Changeset
  import Aquamarine.Vacations.Validators.BookingValidator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :period, EctoRange.Date
    field :start_date, :date, virtual: true
    field :end_date, :date, virtual: true
    field :state, Ecto.Enum, values: [:reserved, :canceled], default: :reserved
    field :total_price, :decimal

    belongs_to :place, Aquamarine.Vacations.Place
    belongs_to :user, Aquamarine.Accounts.User

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

  def cancel_changeset(booking, attrs) do
    booking
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end
end
