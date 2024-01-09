defmodule Triominos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TriominosWeb.Telemetry,
      Triominos.Repo,
      {DNSCluster, query: Application.get_env(:triominos, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Triominos.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Triominos.Finch},
      # Start a worker by calling: Triominos.Worker.start_link(arg)
      # {Triominos.Worker, arg},
      # Start to serve requests, typically the last entry
      TriominosWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Triominos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TriominosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
