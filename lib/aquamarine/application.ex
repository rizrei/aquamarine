defmodule Aquamarine.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AquamarineWeb.Telemetry,
      Aquamarine.Repo,
      {DNSCluster, query: Application.get_env(:aquamarine, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Aquamarine.PubSub},
      # Start a worker by calling: Aquamarine.Worker.start_link(arg)
      # {Aquamarine.Worker, arg},
      # Start to serve requests, typically the last entry
      AquamarineWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aquamarine.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AquamarineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
