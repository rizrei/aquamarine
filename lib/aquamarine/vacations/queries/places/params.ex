defmodule Aquamarine.Vacations.Queries.Places.Params do
  @moduledoc """
  Validates and normalizes parameters for Places query.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Aquamarine.Vacations.Queries.Places.Params.{OrderBy, Filter}

  @primary_key false
  embedded_schema do
    field :limit, :integer

    embeds_one(:order_by, OrderBy)
    embeds_one(:filter, Filter)
  end

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:validate)
    |> compact()
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:limit])
    |> validate_number(:limit, greater_than: 1)
    |> cast_embed(:order_by, with: &OrderBy.changeset/2)
    |> cast_embed(:filter, with: &Filter.changeset/2)
  end

  defp compact({:ok, struct}), do: {:ok, do_compact(struct)}
  defp compact(error), do: error

  defp do_compact(struct), do: struct |> Map.from_struct() |> Enum.reduce(%{}, &do_compact/2)
  defp do_compact({_k, nil}, acc), do: acc
  defp do_compact({k, %Date{} = v}, acc), do: Map.put(acc, k, v)
  defp do_compact({k, %{} = v}, acc), do: Map.put(acc, k, do_compact(v))
  defp do_compact({k, %_{} = v}, acc), do: Map.put(acc, k, do_compact(v))
  defp do_compact({k, v}, acc), do: Map.put(acc, k, v)
end
