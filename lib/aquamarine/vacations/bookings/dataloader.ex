defmodule Aquamarine.Vacations.Bookings.Dataloader do
  import Ecto.Query

  alias Aquamarine.Repo
  alias Aquamarine.Vacations.Booking

  def datasource, do: Dataloader.Ecto.new(Repo, query: &query/2)

  def query(Booking, %{scope: :place, limit: limit}) do
    Booking
    |> where(state: :reserved)
    |> order_by([b], desc: fragment("lower(?)", b.period))
    |> limit(^limit)
  end

  def query(Booking, %{scope: :user}) do
    Booking
    |> order_by([b], asc: fragment("lower(?)", b.period))
  end

  def query(queryable, _), do: queryable
end
