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

  alias TriominosWeb.Piece

  # next: grid logic
  # next: draggable div
  # next: draggable piece
  # next: grid snap
  # next: piece place highlight
  # next: piece place validation

  # x_values = Enum.to_list(-55..55)
  #   y_values = Enum.to_list(-55..55)

  #   grid = for x <- x_values, y <- y_values, do: [x, y]

  #   Enum.chunk_every(grid, 4)

  # like this? Or ?
  # Or should it not be a grid an just be relative values, like a vector?
  # most elegant is likely a vector, but then we need to calculate the position of the piece

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
    pool = Enum.reject(@pieces, fn x -> x in hand end)

    # add first piece to board

    # this seems wrong, should be taking pipe |> operations, how does that work?
    board = Enum.take_random(pool, 1)
    first_piece = Enum.at(board, 0)
    first_piece = Piece.set_x(first_piece, 20)
    first_piece = Piece.set_y(first_piece, 20)
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
          <% [a, b, c, d, e, f] = piece.value %>
          <div class="piece-shape">
            <svg viewBox="0 0 100 86.6" class="absolute inset-0 fill-white">
              <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" />
              <polygon :if={a == -1} points="0 0 100 0 50 86.6" />
            </svg>
            <svg viewBox="0 0 100 86.6" class="absolute inset-0 fill-white">
              <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" />
              <polygon :if={a == -1} points="0 0 100 0 50 86.6" />
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
        </div>
      </div>

      <%!-- topbar --%>
      <div class="absolute inset-x-0 top-0 h-16 border z-40 bg-darkgray">
        topbar
      </div>

      <%!-- pool --%>
      <div class="absolute w-[50vh] h-[50vh] top-0 right-0 hover:h-[75vh] hover:w-[75vh] transition-all border rounded-full translate-x-1/2 -translate-y-1/2 flex items-end z-20">
        pool
      </div>

      <%!-- hand --%>
      <div class="absolute inset-x-0 bottom-0 h-24 z-30 bg-darkblue">
        <div class="flex gap-4 no-wrap overflow-scroll" id="hand" phx-hook="Hand">
          <%= for piece <- @hand do %>
            <% [a, b, c, d, e, f] = piece.value %>
            <div phx-value-piece={piece.id} id={piece.id} class="draggable-piece select-none">
              <div class="piece-shape">
                <svg viewBox="0 0 100 86.6" class="absolute inset-0 fill-white">
                  <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" />
                  <polygon :if={a == -1} points="0 0 100 0 50 86.6" />
                </svg>
                <svg viewBox="0 0 100 86.6" class="absolute inset-0 fill-white">
                  <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" />
                  <polygon :if={a == -1} points="0 0 100 0 50 86.6" />
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
            </div>
          <% end %>
        </div>
      </div>

      <%!-- board --%>
      <div class="absolute inset-0 z-10 bg-blue overflow-hidden">
        <div id="board" phx-hook="Board">
          <%= for piece <- @board do %>
            <% [a, b, c, d, e, f] = piece.value %>
            <div
              class="piece absolute left-0 top-0"
              style={"transform: translateX(#{piece.x * 50}px) translateY(#{piece.y * 68.6}px)"}
            >
              <div phx-value-piece={piece.id} class="piece-shape select-none">
                <svg viewBox="0 0 100 86.6" class="absolute inset-0">
                  <polygon :if={a != -1} points="50 0 0 86.6 100 86.6" style="fill:white" />
                  <polygon :if={a == -1} points="0 0 100 0 50 86.6" style="fill:white" />
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
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("place", %{"piece" => id}, socket) do
    piece = Enum.find(@pieces, fn x -> x.id == id end)

    # remove piece from hand
    hand = Enum.reject(socket.assigns.hand, fn x -> x.id == id end)

    # determine location later from frontend
    piece = Piece.set_x(piece, 21)
    piece = Piece.set_y(piece, 20)

    # [a1, b1, c1, d1, e1, f1] = Piece.get_value(piece)

    # left_neighbour =
    #   Enum.find(socket.assigns.board, fn x -> x.x == piece.x - 1 && x.y == piece.y end)

    # right_neighbour =
    #   Enum.find(socket.assigns.board, fn x -> x.x == piece.x+1 && x.y == piece.y end)

    # A=B + E=D or F = A + D = C
    # if left_neighbour != nil do
    #   [a2, b2, c2, d2, _e2, _f2] = Piece.get_value(left_neighbour)
    #   IO.inspect(a1 == b2 || e1 == d2)
    #   IO.inspect(f1 == a2 || d1 == c2)
    # end

    # # B = A D = E or A = F C = D
    # if right_neighbour != nil do
    #   [_a2, b2, _c2, d2, _e2, _f2] = Piece.get_value(left_neighbour)
    #   IO.inspect(a1 == b2 && e1 == d2)
    #   IO.inspect(a1 == b2 && e1 == d2)
    # end

    # IO.inspect(left_neighbour)

    # add piece to board
    board = socket.assigns.board ++ [piece]

    # add new piece to pieces
    hand = hand ++ Enum.take_random(socket.assigns.pool, 1)

    # remove piece from pool
    pool = Enum.reject(socket.assigns.pool, fn x -> x in hand end)
    {:noreply, assign(socket, hand: hand, pool: pool, board: board, dragging: nil)}
  end

  def handle_event("rotate", %{"piece" => _id}, socket) do
    dragging = Piece.rotate(socket.assigns.dragging)
    {:noreply, assign(socket, dragging: dragging)}
  end

  def handle_event("drag_start", %{"piece" => id}, socket) do
    piece = Enum.find(@pieces, fn x -> x.id == id end)
    {:noreply, assign(socket, dragging: piece)}
  end

  def handle_event("drag_end", %{"piece" => _id}, socket) do
    {:noreply, assign(socket, dragging: nil)}
  end
end
