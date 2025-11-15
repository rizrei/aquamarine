defmodule AquamarineWeb.Router do
  use AquamarineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AquamarineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'"}
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug AquamarineWeb.Plugs.SetCurrentUser
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: AquamarineWeb.GraphQL.Schema,
      analyze_complexity: true,
      max_complexity: 50

    if Mix.env() == :dev do
      # internal interface for testing
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: AquamarineWeb.GraphQL.Schema,
        socket: AquamarineWeb.UserSocket,
        interface: :playground
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:aquamarine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AquamarineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
