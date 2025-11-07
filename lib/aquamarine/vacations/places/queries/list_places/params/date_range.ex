defmodule Aquamarine.Vacations.Places.Queries.ListPlaces.Params.DateRange do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :start_date, :date
    field :end_date, :date
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:start_date, :end_date])
    |> validate_required([:start_date, :end_date])
    |> validate_dates()
  end

  defp validate_dates(%Ecto.Changeset{valid?: true} = changeset) do
    with %Date{} = lower <- get_field(changeset, :start_date),
         %Date{} = uppeer <- get_field(changeset, :end_date),
         :gt <- Date.compare(lower, uppeer) do
      add_error(changeset, :start_date, "cannot be after :end_date")
    else
      _ -> changeset
    end
  end

  defp validate_dates(changeset) do
    changeset
  end
end
