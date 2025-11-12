defmodule AquamarineWeb.Plugs.SetCurrentUser do
  @moduledoc """
  Plug to set the current authenticated user in the Absinthe context.
  """

  @behaviour Plug

  import Plug.Conn

  alias Aquamarine.Guardian

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user, %{"typ" => "access"}} <- Guardian.resource_from_token(token) do
      %{current_user: user, access_token: token}
    else
      _ -> %{}
    end
  end
end
