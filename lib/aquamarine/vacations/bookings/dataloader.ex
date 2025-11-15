defmodule Aquamarine.Vacations.Bookings.Dataloader do
  @moduledoc false

  import Ecto.Query

  alias Aquamarine.Vacations.Booking

  def datasource, do: Dataloader.Ecto.new(Aquamarine.Repo, query: &query/2)

  def query(BookingDL, %{scope: :place} = params) do
    Booking
    |> where(state: :reserved)
    |> order_by([b], desc: fragment("lower(?)", b.period))
    |> limit(^params[:limit])
    |> offset(^params[:offset])
  end

  def query(BookingDL, %{scope: :user} = params) do
    Booking
    |> order_by([b], asc: fragment("lower(?)", b.period))
    |> limit(^params[:limit])
    |> offset(^params[:offset])
  end

  def query(queryable, _args), do: queryable
end
