defmodule Aquamarine.Vacations.Places.Queries.ListPlaces.Params.Filter do
  @moduledoc """
  Filtering parameters for Places query.

  Supports:

    * `search` — substring in place name/description
    * `wifi` — only places with Wi-Fi
    * `pet_friendly` — allow pets
    * `pool` — must have a swimming pool
    * `guest_count` — min amount of guests the place must accommodate
    * `available_between` — date range of availability (see `DateRange.t/0`)
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Aquamarine.Vacations.Places.Queries.ListPlaces.Params.DateRange

  @typedoc """
  Struct of normalized filter parameters.
  """
  @type t :: %__MODULE__{
          search: String.t() | nil,
          wifi: boolean() | nil,
          pet_friendly: boolean() | nil,
          pool: boolean() | nil,
          guest_count: pos_integer() | nil,
          available_between: DateRange.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :search, :string
    field :wifi, :boolean
    field :pet_friendly, :boolean
    field :pool, :boolean
    field :guest_count, :integer

    embeds_one :available_between, DateRange
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:search, :wifi, :pet_friendly, :pool, :guest_count])
    |> validate_length(:search, min: 2)
    |> validate_number(:guest_count, greater_than: 0)
    |> cast_embed(:available_between, with: &DateRange.changeset/2)
  end
end
