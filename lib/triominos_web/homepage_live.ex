defmodule TriominosWeb.HomepageLive do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    Logger.info("homepage")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <button phx-click="new_game">New Game!</button>
    </div>
    """
  end

  def handle_event("new_game", _params, socket) do
    game_id = Enum.random(1..1000)
    path = "/game-#{game_id}"
    {:noreply, push_redirect(socket, to: path)}
  end
end
