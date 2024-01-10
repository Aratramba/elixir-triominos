defmodule TriominosWeb.Piece do
  defstruct id: nil, value: nil, x: nil, y: nil

  @doc """
  Create a new piece

  id: a string of three digits
  value: a list of six values, three digits and three -1 in between

  A triangle piece can be placed 6 ways, this is representated by this map
   A    B    C    D    E    F
  [-1, "1", -1, "2", -1, "3"]

  where -1 is an empty space

  This can be visually translated to this triangle


  [ F  A  B ]
  [ E  D  C ]

  pointing up
  [ x  A  x ]
  [ E  x  C ]

  pointing down
  [ F  x  B ]
  [ x  D  x ]
  """

  def new(id) do
    [a, b, c] = String.split(id, "", trim: true)
    value = [String.to_integer(a), -1, String.to_integer(b), -1, String.to_integer(c), -1]
    %__MODULE__{id: id, value: value}
  end

  @doc """
  Rotate a piece clockwise
  by moving the last value to the front
  """

  def rotate(item) do
    [a, b, c, d, e, f] = item.value
    new_value = [f, a, b, c, d, e]
    %__MODULE__{item | value: new_value}
  end

  def get_value(%__MODULE__{value: value}), do: value

  def get_id(%__MODULE__{id: id}), do: id

  def get_x(%__MODULE__{x: x}), do: x

  def get_y(%__MODULE__{y: y}), do: y

  def set_x(%__MODULE__{} = piece, x) do
    %__MODULE__{piece | x: x}
  end

  def set_y(%__MODULE__{} = piece, y) do
    %__MODULE__{piece | y: y}
  end
end

defmodule TriominosWeb.GameLive do
  use Phoenix.LiveView
  use Phoenix.Component

  alias TriominosWeb.Piece

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

  def mount(_params, _session, socket) do
    hand = Enum.take_random(@pieces, 5)

    # remove pieces from pool
    pool = Enum.reject(@pieces, fn p -> p in hand end)

    # add first piece to board

    # this seems wrong, should be taking pipe |> operations, how does that work?
    board = Enum.take_random(pool, 1)
    first_piece = Enum.at(board, 0)
    first_piece = Piece.set_x(first_piece, 25)
    first_piece = Piece.set_y(first_piece, 17)
    board = [first_piece]
    IO.inspect(board)

    {:ok, assign(socket, hand: hand, pool: pool, board: board, dragging: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-5 h-screen overflow-hidden relative">
      <div id="dragger" class="absolute inset-0 z-50">
        <% piece = @dragging %>
        <div
          :if={@dragging != nil}
          id="dragging"
          phx-hook="Dragging"
          phx-value-piece={piece.id}
          id={piece.id}
          class="draggable-piece select-none"
        >
          <TriominosWeb.GameLive.shape value={piece.value} id={piece.id} draggable={false} />
        </div>
      </div>

      <%!-- topbar --%>
      <div class="absolute inset-x-0 top-0 h-16 border z-40 bg-darkgray">
        topbar
      </div>

      <%!-- pool --%>
      <div class="absolute w-[50vh] h-[50vh] top-0 right-0 hover:h-[75vh] hover:w-[75vh] transition-all border rounded-full translate-x-1/2 -translate-y-1/2 flex items-end overflow-scroll z-50">
        <%= for piece <- @pool do %>
          <% randomX = Enum.random(0..75)
          randomY = Enum.random(0..75)
          randomR = Enum.random(0..360) %>

          <div
            class="piece absolute"
            style={"transform: rotate(#{randomR}deg); top: #{randomY}%; left: #{randomX}%"}
            phx-click="refill"
          >
            <TriominosWeb.GameLive.shape value={piece.value} id={piece.id} draggable={false} />
          </div>
        <% end %>
      </div>

      <%!-- hand --%>
      <div class="absolute inset-x-0 bottom-0 h-24 z-30 bg-darkblue">
        <div class="flex gap-4 flex-nowrap overflow-scroll" id="hand" phx-hook="Hand">
          <%= for piece <- @hand do %>
            <TriominosWeb.GameLive.shape value={piece.value} id={piece.id} draggable={true} />
          <% end %>
        </div>
      </div>

      <%!-- board --%>
      <div class="absolute inset-0 z-10 bg-blue overflow-hidden">
        <div id="board" phx-hook="Board" class="w-[2000px] h-[2000px]">
          <%= for piece <- @board do %>
            <div
              class="piece absolute left-0 top-0"
              style={"transform:
                translateX(calc(#{piece.x}*var(--piece-width)/2))
                translateY(calc(#{piece.y}*var(--piece-height)))"}
            >
              <TriominosWeb.GameLive.shape value={piece.value} id={piece.id} draggable={false} />
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def shape(assigns) do
    ~H"""
    <% [a, b, c, d, e, f] = @value %>
    <div
      class="select-none shrink-0 block relative w-[100px] h-[86.6px]"
      data-draggable={@draggable == true}
      data-id={@id}
    >
      <svg viewBox="0 0 100 86.6" class="absolute inset-0">
        <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" style="fill:white" class="drop-shadow" />
        <polygon :if={a == -1} points="0 0 100 0 50 86.6" style="fill:white" class="drop-shadow" />
      </svg>
      <span :if={a > -1} class="absolute -translate-x-1/2 left-1/2 top-0"><%= a %></span>
      <span :if={b > -1} class="absolute -translate-x-full right-0 top-0"><%= b %></span>
      <span :if={c > -1} class="absolute -translate-x-full right-0 bottom-0">
        <%= c %>
      </span>
      <span :if={d > -1} class="absolute -translate-x-1/2 left-1/2 bottom-0">
        <%= d %>
      </span>
      <span :if={e > -1} class="absolute translate-x-full left-0 bottom-0"><%= e %></span>
      <span :if={f > -1} class="absolute translate-x-full left-0 top-0"><%= f %></span>
    </div>
    """
  end

  def handle_event("refill", _, socket) do
    hand = socket.assigns.hand ++ Enum.take_random(socket.assigns.pool, 1)
    pool = Enum.reject(socket.assigns.pool, fn p -> p in hand end)
    {:noreply, assign(socket, hand: hand, pool: pool)}
  end

  def handle_event("rotate", %{"piece" => _id}, socket) do
    dragging = Piece.rotate(socket.assigns.dragging)
    {:noreply, assign(socket, dragging: dragging)}
  end

  def handle_event("drag_start", %{"piece" => id}, socket) do
    piece = Enum.find(@pieces, fn p -> p.id == id end)
    {:noreply, assign(socket, dragging: piece)}
  end

  def handle_event("drag_end", %{"x" => x, "y" => y}, socket) do
    IO.puts(to_string(x) <> " " <> to_string(y))

    # check if piece on top of another
    on_top = Enum.find(socket.assigns.board, fn p -> p.x == x and p.y == y end)

    if on_top != nil do
      IO.puts("rejected: on top of another piece")
    end

    if !on_top do
      piece = socket.assigns.dragging

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
      {:noreply, assign(socket, hand: hand, pool: pool, board: board, dragging: nil)}
    else
      {:noreply, assign(socket, dragging: nil)}
    end
  end
end
