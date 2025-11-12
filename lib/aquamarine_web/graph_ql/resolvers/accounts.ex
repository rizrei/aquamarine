defmodule AquamarineWeb.GraphQL.Resolvers.Accounts do
  import AquamarineWeb.GraphQL.Errors

  alias Aquamarine.Accounts
  alias Accounts.{SignUp, SignIn, SignOut, RefreshToken}

  @spec sign_up(any(), SignUp.sign_up_attrs(), any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def sign_up(_, params, _) do
    case SignUp.call(params) do
      {:ok, result} -> {:ok, result}
      {:error, %Ecto.Changeset{} = changeset} -> invalid_changeset_error(changeset)
      {:error, error} -> {:error, message: inspect(error)}
    end
  end

  @spec sign_in(any(), SignIn.sign_in_attrs(), any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def sign_in(_, params, _) do
    case SignIn.call(params) do
      {:ok, result} -> {:ok, result}
      {:error, :record_not_found} -> record_not_found_error()
      {:error, error} -> {:error, message: inspect(error)}
    end
  end

  @spec refresh_token(any(), %{refresh_token: String.t()}, any()) ::
          {:ok, Accounts.session()} | {:error, map()}
  def refresh_token(_, params, _) do
    case RefreshToken.call(params) do
      {:ok, result} -> {:ok, result}
      {:error, :record_not_found} -> record_not_found_error()
      {:error, :token_expired} -> {:error, message: "Refresh token expired"}
      {:error, :invalid_token} -> {:error, message: "Invalid token"}
      {:error, :invalid_token_type} -> {:error, message: "Invalid token type"}
      {:error, :token_not_found} -> {:error, message: "Refresh token not found"}
      {:error, error} -> {:error, message: inspect(error)}
    end
  end

  @spec sign_out(any(), any(), %{context: %{access_token: String.t()}}) ::
          {:ok, %{success: boolean()}} | {:error, map()}
  def sign_out(_, _, %{context: %{access_token: access_token}}) do
    case SignOut.call(access_token) do
      {:ok, result} -> {:ok, result}
      {:error, :token_expired} -> {:error, message: "Access token expired"}
      {:error, :invalid_token} -> {:error, message: "Invalid token"}
      {:error, :invalid_token_type} -> {:error, message: "Invalid token type"}
      {:error, error} -> {:error, message: inspect(error)}
    end
  end

  def sign_out(_, _, _), do: {:error, message: "Access token not found"}
end
