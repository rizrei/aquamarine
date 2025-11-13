defmodule Aquamarine.Accounts.Dataloader do
  @moduledoc false

  use Ecto.Schema

  alias Aquamarine.Repo

  def datasource, do: Dataloader.Ecto.new(Repo, query: &query/2)

  def query(queryable, _), do: queryable
end
