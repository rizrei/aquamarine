defmodule Aquamarine.Vacations.Places.Queries.ListPlaces.Params.OrderBy do
  @moduledoc """
  Sorting parameters for Places query.

  Each sortable field may be `:asc` or `:desc`.

  Supported fields:
    * `name`
    * `max_guests`
  """

  use Ecto.Schema
  import Ecto.Changeset

  @typedoc """
  Struct of normalized sorting parameters.
  """
  @type t :: %__MODULE__{
          name: :asc | :desc | nil,
          max_guests: :asc | :desc | nil
        }

  @primary_key false
  embedded_schema do
    field :name, Ecto.Enum, values: [:asc, :desc]
    field :max_guests, Ecto.Enum, values: [:asc, :desc]
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    cast(schema, attrs, [:name, :max_guests])
  end
end
