defmodule TriominosWeb.GameController do
  use TriominosWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def game(conn, %{"game" => game}) do
    render(conn, :game, game: game)
  end
end
