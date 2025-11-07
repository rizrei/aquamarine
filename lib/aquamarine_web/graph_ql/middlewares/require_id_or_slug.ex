defmodule AquamarineWeb.GraphQl.Middlewares.RequireIdOrSlug do
  @behaviour Absinthe.Middleware

  @impl true
  def call(%{arguments: %{id: _, slug: _}} = res, _config),
    do: Absinthe.Resolution.put_result(res, error())

  def call(%{arguments: %{id: _}} = res, _config), do: res
  def call(%{arguments: %{slug: _}} = res, _config), do: res
  def call(res, _config), do: Absinthe.Resolution.put_result(res, error())

  defp error, do: {:error, message: "You must provide either `id` or `slug`"}
end
