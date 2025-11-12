defmodule AquamarineWeb.GraphQL.Middlewares.IdOrSlug do
  @moduledoc """
  Absinthe middleware ensuring that resolver receives *either* `id` or `slug`,
  but not both and not none.

  Use this middleware on fields where the resolver expects exactly one lookup
  identifier. If both fields are provided or both omitted, an error is returned.

  ## Example

      field :place, :place do
        arg :id, :id
        arg :slug, :string
        middleware AquamarineWeb.GraphQL.Middlewares.IdOrSlug
        resolve &Resolvers.Vacations.Places.place/3
      end
  """

  @behaviour Absinthe.Middleware

  @impl true
  @spec call(Absinthe.Resolution.t(), any()) :: Absinthe.Resolution.t()
  def call(%{arguments: %{id: _, slug: _}} = res, _config),
    do: Absinthe.Resolution.put_result(res, error())

  def call(%{arguments: %{id: _}} = res, _config), do: res
  def call(%{arguments: %{slug: _}} = res, _config), do: res
  def call(res, _config), do: Absinthe.Resolution.put_result(res, error())

  defp error, do: {:error, message: "You must provide either `id` or `slug`"}
end
