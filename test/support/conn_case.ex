defmodule AquamarineWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AquamarineWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint AquamarineWeb.Endpoint

      use AquamarineWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AquamarineWeb.ConnCase
      import Aquamarine.Factory

      def graphql_query(conn, query, variables \\ %{}) do
        post(conn, "/graphql", %{query: query, variables: variables})
      end
    end
  end

  setup tags do
    Aquamarine.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def graphql_error_messages(errors) do
    Enum.map(errors, fn error -> error["message"] end)
  end

  def graphql_error_details(errors) do
    Enum.map(errors, fn error -> error["details"] end)
  end
end
