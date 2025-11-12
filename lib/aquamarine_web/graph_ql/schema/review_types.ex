defmodule AquamarineWeb.GraphQL.Schema.ReviewTypes do
  @moduledoc """
  GraphQL types, queries and mutations related to Review management.
  """

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias AquamarineWeb.GraphQL.Resolvers.Vacations.Reviews
  alias AquamarineWeb.GraphQL.Middlewares

  object :review do
    field :id, non_null(:id)
    field :rating, non_null(:integer)
    field :comment, non_null(:string)
    field :inserted_at, non_null(:naive_datetime)

    field :user, non_null(:user), resolve: dataloader(Accounts)
    field :place, non_null(:place), resolve: dataloader(Places)
  end

  object :review_mutations do
    @desc "Create review"
    field :create_review, :review do
      arg(:place_id, non_null(:id))
      arg(:rating, non_null(:integer))
      arg(:comment, non_null(:string))

      middleware(Middlewares.Authenticate)

      resolve(&Reviews.create_review/3)
    end
  end
end
