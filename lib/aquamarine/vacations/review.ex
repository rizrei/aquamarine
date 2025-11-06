defmodule Aquamarine.Vacations.Review do
  use Ecto.Schema

  import Ecto.Changeset

  alias Aquamarine.Vacations.Place
  alias Aquamarine.Vacations.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          rating: integer() | nil,
          comment: String.t() | nil,
          place_id: Ecto.UUID.t() | nil,
          place: Place.t() | Ecto.Association.NotLoaded.t(),
          user_id: Ecto.UUID.t() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reviews" do
    field :rating, :integer
    field :comment, :string

    belongs_to :place, Place
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(review, attrs) do
    required_fields = [:rating, :comment, :place_id]

    review
    |> cast(attrs, required_fields)
    |> validate_required(required_fields)
    |> assoc_constraint(:place)
    |> assoc_constraint(:user)
  end
end
