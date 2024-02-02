defmodule TriominosWeb.GameLive do
  use Phoenix.LiveView
  use Phoenix.Component

  alias TriominosWeb.Board
  alias TriominosWeb.Piece

  embed_templates "game_live_html/*"

  require Logger

  # TODO: generate this list
  @pieces [
    Piece.new("000"),
    Piece.new("001"),
    Piece.new("002"),
    Piece.new("003"),
    Piece.new("004"),
    Piece.new("005"),
    Piece.new("011"),
    Piece.new("012"),
    Piece.new("013"),
    Piece.new("014"),
    Piece.new("015"),
    Piece.new("022"),
    Piece.new("023"),
    Piece.new("024"),
    Piece.new("025"),
    Piece.new("033"),
    Piece.new("034"),
    Piece.new("035"),
    Piece.new("044"),
    Piece.new("045"),
    Piece.new("055"),
    Piece.new("111"),
    Piece.new("112"),
    Piece.new("113"),
    Piece.new("114"),
    Piece.new("115"),
    Piece.new("122"),
    Piece.new("123"),
    Piece.new("124"),
    Piece.new("125"),
    Piece.new("133"),
    Piece.new("134"),
    Piece.new("135"),
    Piece.new("144"),
    Piece.new("145"),
    Piece.new("155"),
    Piece.new("222"),
    Piece.new("223"),
    Piece.new("224"),
    Piece.new("225"),
    Piece.new("233"),
    Piece.new("234"),
    Piece.new("235"),
    Piece.new("244"),
    Piece.new("245"),
    Piece.new("255"),
    Piece.new("333"),
    Piece.new("334"),
    Piece.new("335"),
    Piece.new("344"),
    Piece.new("345"),
    Piece.new("355"),
    Piece.new("444"),
    Piece.new("445"),
    Piece.new("455"),
    Piece.new("555")
  ]

  def mount(%{"id" => id}, _session, socket) do
    Logger.info(id)

    # a two-player game uses nine pieces per player to start,
    # three or four players use seven pieces,
    #  and five or six players use six pieces.

    num_pieces = 9

    # generate hand
    hand = Enum.take_random(@pieces, num_pieces)

    # remove pieces from pool
    pool = Enum.reject(@pieces, fn p -> p in hand end)

    # add first piece to board
    board =
      Enum.take_random(pool, 1)

    first_piece =
      Enum.at(board, 0)
      |> Piece.set_x(30)
      |> Piece.set_y(30)

    board = [first_piece]

    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    socket =
      socket
      |> assign(hand: hand)
      |> assign(pool: pool)
      |> assign(board: board)
      |> assign(dragging: nil)
      |> assign(move_status: :default)
      |> assign(start: Time.utc_now())
      |> assign(timer: 0)

    {:ok, socket}
  end

  def handle_event("refill", _, socket) do
    hand = socket.assigns.hand ++ Enum.take_random(socket.assigns.pool, 1)
    pool = Enum.reject(socket.assigns.pool, fn p -> p in hand end)
    {:noreply, assign(socket, hand: hand, pool: pool)}
  end

  def handle_event("rotate", %{"piece" => _id, "reverse" => reverse}, socket) do
    dragging =
      if !reverse,
        do: Piece.rotate(socket.assigns.dragging, :cw),
        else: Piece.rotate(socket.assigns.dragging, :ccw)

    {:noreply, assign(socket, dragging: dragging)}
  end

  def handle_event("drag_start", %{"piece" => id}, socket) do
    piece = Enum.find(@pieces, fn p -> p.id == id end)
    {:noreply, assign(socket, dragging: piece)}
  end

  def handle_event("drag_move", %{"x" => x, "y" => y}, socket) do
    piece = socket.assigns.dragging

    {status} =
      Board.validate(piece, %{
        "x" => x,
        "y" => y,
        "board" => socket.assigns.board
      })

    if status == :valid do
      {:noreply, assign(socket, move_status: :valid)}
    else
      {:noreply, assign(socket, move_status: status)}
    end
  end

  def handle_event("drag_end", %{"x" => x, "y" => y}, socket) do
    piece = socket.assigns.dragging
    {status} = Board.validate(piece, %{"x" => x, "y" => y, "board" => socket.assigns.board})

    if status == :valid do
      # remove piece from hand
      hand = Enum.reject(socket.assigns.hand, fn p -> p.id == piece.id end)

      # determine location later from frontend
      piece = Piece.set_x(piece, x)
      piece = Piece.set_y(piece, y)

      # add piece to board
      board = socket.assigns.board ++ [piece]

      # add new piece to pieces
      hand = Enum.take_random(socket.assigns.pool, 1) ++ hand

      # remove piece from pool
      pool = Enum.reject(socket.assigns.pool, fn p -> p in hand end)

      {:noreply,
       assign(socket, hand: hand, pool: pool, board: board, dragging: nil, move_status: :default)}
    else
      {:noreply, assign(socket, dragging: nil, move_status: status)}
    end
  end

  def handle_info(:tick, socket) do
    diff = Time.diff(Time.utc_now(), socket.assigns.start, :second)

    timer =
      cond do
        diff > 60 -> "#{div(diff, 60)}:#{rem(diff, 60)}"
        true -> "#{diff}"
      end

    {:noreply, assign(socket, timer: timer)}
  end
end
