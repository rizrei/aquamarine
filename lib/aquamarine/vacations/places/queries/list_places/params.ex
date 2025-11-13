defmodule Aquamarine.Vacations.Places.Queries.ListPlaces.Params do
  @moduledoc """
  Validates and normalizes parameters for Places query.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Aquamarine.Vacations.Places.Queries.ListPlaces.Params.{OrderBy, Filter}

  @typedoc """
  Struct representing normalized parameters for `list_places/1`.

  Fields:
    * `limit` — maximum number of returned places
    * `order_by` — order fields (see `OrderBy.t/0`)
    * `filter` — filtering rules (see `Filter.t/0`)
  """
  @type t :: %__MODULE__{
          limit: integer() | nil,
          order_by: OrderBy.t() | nil,
          filter: Filter.t() | nil
        }

  @typedoc """
  Raw input parameters to `list_places/1` before validation.

  Example:

      %{
        limit: 5,
        order_by: %{name: :asc, max_guests: :desc},
        filter: %{
          pool: true,
          wifi: true,
          guest_count: 2,
          search: "Yurt",
          available_between: %{start_date: ~D[2025-09-01], end_date: ~D[2025-09-05]}
        }
      }
  """
  @type criteria :: %{
          optional(:limit) => integer(),
          optional(:order_by) => map(),
          optional(:filter) => map()
        }

  @primary_key false
  embedded_schema do
    field :limit, :integer

    embeds_one(:order_by, OrderBy)
    embeds_one(:filter, Filter)
  end

  @spec validate(map()) :: {:ok, criteria()} | {:error, Ecto.Changeset.t()}
  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:validate)
    |> compact()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:limit])
    |> validate_number(:limit, greater_than_or_equal_to: 1)
    |> cast_embed(:order_by, with: &OrderBy.changeset/2)
    |> cast_embed(:filter, with: &Filter.changeset/2)
  end

  defp compact({:ok, struct}), do: {:ok, do_compact(struct)}
  defp compact(error), do: error

  defp do_compact(struct), do: struct |> Map.from_struct() |> Enum.reduce(%{}, &do_compact/2)
  defp do_compact({_k, nil}, acc), do: acc
  defp do_compact({k, %Date{} = v}, acc), do: Map.put(acc, k, v)
  defp do_compact({k, %{} = v}, acc), do: Map.put(acc, k, do_compact(v))
  defp do_compact({k, v}, acc), do: Map.put(acc, k, v)
end
