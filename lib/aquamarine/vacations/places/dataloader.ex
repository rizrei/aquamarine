defmodule Aquamarine.Vacations.Places.Dataloader do
  @moduledoc false

  alias Aquamarine.Repo

  def datasource, do: Dataloader.Ecto.new(Repo, query: &query/2)

  def query(queryable, _), do: queryable
end
