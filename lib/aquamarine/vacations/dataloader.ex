defmodule Aquamarine.Vacations.Dataloader do
  import Ecto.Query
  alias Aquamarine.Repo

  alias Aquamarine.Vacations.{Place, Booking, Review}
  alias Aquamarine.Accounts.User

  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

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

  def query(queryable, _) do
    queryable
  end
end
