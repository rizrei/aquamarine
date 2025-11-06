defmodule Aquamarine.Vacations.Queries.Places.Params.Filter do
  use Ecto.Schema

  import Ecto.Changeset

  alias Aquamarine.Vacations.Queries.Places.Params.DateRange

  @primary_key false
  embedded_schema do
    field :search, :string
    field :wifi, :boolean
    field :pet_friendly, :boolean
    field :pool, :boolean
    field :guest_count, :integer

    embeds_one(:available_between, DateRange)
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:search, :wifi, :pet_friendly, :pool, :guest_count])
    |> validate_length(:search, min: 2)
    |> validate_number(:guest_count, greater_than: 0)
    |> cast_embed(:available_between, with: &DateRange.changeset/2)
  end
end
