defmodule Aquamarine.Vacations.Queries.Places.Params.OrderBy do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, Ecto.Enum, values: [:asc, :desc]
    field :max_guests, Ecto.Enum, values: [:asc, :desc]
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    cast(schema, attrs, [:name, :max_guests])
  end
end
