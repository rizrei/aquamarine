defmodule Aquamarine.Accounts.Dataloader do
  use Ecto.Schema

  alias Aquamarine.Repo
  alias Aquamarine.Accounts.User
  alias Aquamarine.Vacations.{Booking, Review}

  # Dataloader

  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _) do
    queryable
  end
end
