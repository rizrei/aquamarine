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
      # Start the PubSub system
      {Phoenix.PubSub, name: Aquamarine.PubSub},
      # Token cleaner
      {Guardian.DB.Sweeper,
       [interval: Application.get_env(:guardian, Guardian.DB)[:sweep_interval]]},
      AquamarineWeb.Endpoint,
      # Absinthe Subscription
      {Absinthe.Subscription, AquamarineWeb.Endpoint}
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
