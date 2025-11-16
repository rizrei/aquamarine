defmodule Aquamarine.Vacations.Bookings.Validations do
  @moduledoc """
  Booking validator functions.
  """

  import Ecto.Query
  import Ecto.Changeset

  alias Aquamarine.Repo
  alias Aquamarine.Vacations.{Booking, Place}

  def put_period(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :period, %Postgrex.Range{
      lower: get_field(changeset, :start_date),
      upper: get_field(changeset, :end_date)
    })
  end

  def put_period(changeset) do
    changeset
  end

  def put_total_price(%Ecto.Changeset{valid?: true} = changeset) do
    with %Postgrex.Range{lower: lower, upper: upper} <- get_field(changeset, :period),
         %Place{price_per_night: price} <- Repo.get(Place, get_field(changeset, :place_id)) do
      put_change(changeset, :total_price, Decimal.mult(price, Date.diff(upper, lower)))
    else
      _ ->
        add_error(
          changeset,
          :total_price,
          "Cannot calculate total price: invalid period or place"
        )
    end
  end

  def put_total_price(changeset) do
    changeset
  end

  def validate_dates(%Ecto.Changeset{valid?: true} = changeset) do
    with %Date{} = lower <- get_field(changeset, :start_date),
         %Date{} = uppeer <- get_field(changeset, :end_date),
         :gt <- Date.compare(lower, uppeer) do
      add_error(changeset, :start_date, "cannot be after :end_date")
    else
      _ -> changeset
    end
  end

  def validate_dates(changeset) do
    changeset
  end

  def validate_period_available(%Ecto.Changeset{valid?: true} = changeset) do
    with %Postgrex.Range{} = period <- get_field(changeset, :period),
         place_id <- get_field(changeset, :place_id),
         true <- overlapping_bookings?(period, place_id) do
      add_error(changeset, :period, "is not available")
    else
      _ -> changeset
    end
  end

  def validate_period_available(changeset) do
    changeset
  end

  defp overlapping_bookings?(%Postgrex.Range{} = period, place_id) do
    Booking
    |> where([b], b.place_id == ^place_id)
    |> where([b], fragment("? && ?", b.period, ^period))
    |> Repo.exists?()
  end
end
