defmodule AquamarineWeb.GraphQL.Schema.SessionTypes do
  @moduledoc """
  GraphQL types and mutations related to user authentication and session management.
  """

  use Absinthe.Schema.Notation

  alias AquamarineWeb.GraphQL.Resolvers.Accounts
  alias AquamarineWeb.GraphQL.Middlewares

  object :session do
    field :user, non_null(:user)
    field :access_token, non_null(:string)
    field :refresh_token, non_null(:string)
  end

  object :sign_out_result do
    field :success, non_null(:boolean)
  end

  object :session_mutations do
    @desc "Sign up user"
    field :sign_up, :session do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Accounts.sign_up/3)
    end

    @desc "Sign in user"
    field :sign_in, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Accounts.sign_in/3)
    end

    @desc "Sign out the current user (requires authentication)"
    field :sign_out, :sign_out_result do
      middleware(Middlewares.Authenticate)
      resolve(&Accounts.sign_out/3)
    end

    @desc "Create new token pair"
    field :refresh_token, :session do
      arg(:refresh_token, non_null(:string))

      resolve(&Accounts.refresh_token/3)
    end
  end
end
