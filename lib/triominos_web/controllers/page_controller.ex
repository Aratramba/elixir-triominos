defmodule TriominosWeb.PageController do
  use TriominosWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def games(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    IO.puts("Hello games")
    render(conn, :games, layout: false)
  end

  def game(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    IO.puts("Hello game")
    render(conn, :game, layout: false)
  end
end
