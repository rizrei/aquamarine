defmodule Aquamarine.Vacations.Places.Queries.ListPlaces do
  @moduledoc """
  A query module for filtering Places based on parameters.
  """

  import Ecto.Query

  alias Aquamarine.Vacations.{Booking, Place}

  @spec call(map()) :: [Place.t()]
  def call(params) do
    Place
    |> with_filter(params)
    |> with_order(params)
    |> with_limit(params)
    |> with_offset(params)
  end

  defp with_filter(query, %{filter: filters}) do
    Enum.reduce(filters, query, fn
      {:search, term}, query ->
        with_search(query, term)

      {:pet_friendly, pet_friendly}, query ->
        where(query, pet_friendly: ^pet_friendly)

      {:pool, pool}, query ->
        where(query, pool: ^pool)

      {:wifi, wifi}, query ->
        where(query, wifi: ^wifi)

      {:guest_count, guest_count}, query ->
        where(query, [q], q.max_guests >= ^guest_count)

      {:available_between, %{start_date: start_date, end_date: end_date}}, query ->
        with_available_between(query, start_date, end_date)
    end)
  end

  defp with_filter(query, _), do: query

  defp with_search(query, term) do
    p = "%#{term}%"

    where(query, [q], ilike(q.name, ^p) or ilike(q.description, ^p) or ilike(q.location, ^p))
  end

  defp with_available_between(query, start_date, end_date) do
    period = %Postgrex.Range{lower: start_date, upper: end_date}

    bookings =
      Booking
      |> where([b], b.place_id == parent_as(:place).id)
      |> where([b], fragment("? && ?", b.period, ^period))

    query
    |> from(as: :place)
    |> where(not exists(bookings))
  end

  defp with_order(query, %{order_by: order_by}) do
    query
    |> join_assoc_for_ordering(order_by)
    |> order_by(^build_order_list(order_by))
  end

  defp with_order(query, _), do: query

  defp join_assoc_for_ordering(query, _), do: query

  defp build_order_list(order_by_map), do: Enum.map(order_by_map, fn {k, v} -> {v, k} end)

  defp with_limit(query, %{limit: limit}), do: limit(query, ^limit)
  defp with_limit(query, _), do: query

  defp with_offset(query, %{offset: offset}), do: offset(query, ^offset)
  defp with_offset(query, _), do: query
end
