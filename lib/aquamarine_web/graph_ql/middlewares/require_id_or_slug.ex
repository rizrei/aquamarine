defmodule AquamarineWeb.GraphQl.Middlewares.RequireIdOrSlug do
  @behaviour Absinthe.Middleware

  @impl true
  def call(resolution, _config) do
    if id_or_slug_present?(resolution.arguments) do
      Absinthe.Resolution.put_result(
        resolution,
        {:error, message: "You must provide either `id` or `slug`"}
      )
    else
      resolution
    end
  end

  defp id_or_slug_present?(%{id: _, slug: _}), do: false
  defp id_or_slug_present?(args) when is_map_key(args, :id) or is_map_key(args, :slug), do: true
  defp id_or_slug_present?(_), do: false
end
