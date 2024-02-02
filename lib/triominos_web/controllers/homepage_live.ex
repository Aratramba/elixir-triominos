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
      <div class="absolute inset-x-0 top-0 h-[63px] z-50 bg-[url('/images/bg-top.png')] text-white flex gap-10">
        <span class="mt-3 ml-4 font-medium">Triominos</span>
      </div>

      <div class="absolute inset-0 z-10 overflow-hidden">
        <div class="w-screen h-screen grid place-items-center bg-repeat bg-[url('/images/linen.gif')]">
          <button
            phx-click="new_game"
            class="bg-white px-6 py-4 text-lg text-darkblue rounded-md shadow hover:underline border underline-offset-4"
          >
            New Game!
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("new_game", _params, socket) do
    game_id = Enum.random(1..1000)
    path = "/game-#{game_id}"
    {:noreply, push_redirect(socket, to: path)}
  end
end
