defmodule Absinthe.Resolution.RelayHelpers do
  @moduledoc """
  Helpers for Relay connections using Dataloader.
  """

  import Absinthe.Resolution.Helpers, only: [dataloader: 3]

  # connection field :bookings_connection, node_type: :booking do
  #   resolve(fn place, pagination_args, %{ontext: %{loader: loader}} ->
  #     loader
  #     |> Dataloader.load(BookingsDL, {:bookings, params}, place)
  #     |> on_load(fn loader ->
  #       loader
  #       |> Dataloader.get(BookingsDL, {:bookings, params}, place)
  #       |> Absinthe.Relay.Connection.from_list(params) <-- CALLBACK
  #     end)
  #   end)
  # end

  @doc """
  Wrapper for connection field with Dataloader support.
  """
  def connection_dataloader(source, resource, opts \\ []) do
    dataloader(
      source,
      resource,
      Keyword.put(opts, :callback, relay_connection_callback(:from_list))
    )
  end

  defp relay_connection_callback(fn_name) do
    fn item, _parent, args -> apply(Absinthe.Relay.Connection, fn_name, [item, args]) end
  end
end
