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
    board = Enum.take_random(pool, 1)

    first_piece =
      Enum.at(board, 0)
      |> Piece.set_x(55)
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

  # def render(assigns) do
  #   ~H"""
  #   <div class="grid grid-cols-5 h-screen overflow-hidden relative select-none">
  #     <div id="dragger" class="absolute inset-0 z-50">
  #       <div
  #         :if={@dragging != nil}
  #         id="dragging"
  #         phx-hook="Dragging"
  #         phx-value-piece={@dragging.id}
  #         class="absolute left-0 top-0"
  #       >
  #         <span :if={@move_status} class="bg-white/60 rounded-md px-1.5 py-0.5 text-xs">
  #           <%= @move_status %>
  #         </span>
  #         <span />
  #       </div>
  #     </div>

  #     <%!-- pool --%>
  #     <div class="absolute w-[50vh] h-[50vh] top-0 right-0 hover:h-[75vh] hover:w-[75vh] transition-all rounded-full translate-x-1/2 -translate-y-1/2 flex items-end z-50">
  #       <div class="absolute inset-0 bg-[url('/images/bg-main.jpg')] blur-3xl bg-top opacity-80" />
  #       <%= for piece <- @pool do %>
  #         <% randomX = Enum.random(0..55)
  #         randomY = Enum.random(0..55)
  #         randomR = Enum.random(0..360) %>

  #         <div
  #           class="piece absolute"
  #           style={"transform: rotate(#{randomR}deg); bottom: #{randomY}%; left: #{randomX}%"}
  #           phx-click="refill"
  #         >
  #           <.shape
  #             value={piece.value}
  #             id={piece.id}
  #             draggable={false}
  #             show_labels={false}
  #             rotation={piece.rotation}
  #             move_status={false}
  #           />
  #         </div>
  #       <% end %>
  #     </div>

  #     <%!-- topbar --%>
  #     <div class="absolute inset-x-0 top-0 h-[63px] z-50 bg-[url('/images/bg-top.png')] text-white flex gap-10">
  #       <span class="ml-auto text-sm mt-4 mr-4"><%= @timer %></span>
  #     </div>

  #     <%!-- hand --%>
  #     <div class="absolute inset-x-0 bottom-0 z-30 bg-darkblue drop-shadow-[0_-35px_35px_rgba(0,0,0,0.25)]">
  #       <div
  #         class="flex gap-4 justify-center items-center flex-nowrap h-[120px] overflow-scroll"
  #         id="hand"
  #         phx-hook="Hand"
  #       >
  #         <%= for piece <- @hand do %>
  #           <.shape
  #             value={piece.value}
  #             id={piece.id}
  #             draggable={true}
  #             show_labels={true}
  #             rotation={piece.rotation}
  #             move_status={false}
  #           />
  #         <% end %>
  #       </div>
  #     </div>

  #     <%!-- board --%>
  #     <div class="absolute inset-0 z-10 overflow-hidden">
  #       <div
  #         id="board"
  #         phx-hook="Board"
  #         class="w-[10000px] h-[10000px] transform-gpu
  #         bg-repeat
  #         bg-[url('/images/linen.gif')]"
  #       >
  #         <%= for piece <- @board do %>
  #           <div
  #             class="piece absolute left-0 top-0 origin-center"
  #             style={"transform:
  #               translateX(calc(#{piece.x}*var(--piece-width)/2))
  #               translateY(calc(#{piece.y}*var(--piece-height)))"}
  #           >
  #             <.shape
  #               value={piece.value}
  #               id={piece.id}
  #               draggable={false}
  #               show_labels={true}
  #               rotation={0}
  #               move_status={false}
  #             />
  #           </div>
  #         <% end %>

  #         <div :if={@dragging != nil} id="ghost" class="absolute left-0 top-0 transition-transform">
  #           <div class={if @move_status == :no_neighbours, do: "opacity-40", else: "opacity-100"}>
  #             <span class="absolute top-0 left-0">
  #               <.shape
  #                 value={@dragging.value}
  #                 id={@dragging.id}
  #                 draggable={false}
  #                 show_labels={true}
  #                 rotation={0}
  #                 move_status={@move_status}
  #               />
  #             </span>
  #           </div>
  #         </div>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  # def shape(assigns) do
  #   ~H"""
  #   <% [a, b, c, d, e, f] = @value %>
  #   <div
  #     class="select-none shrink-0 block relative w-[100px] h-[86px] origin-[50px_43px]"
  #     data-draggable={@draggable == true}
  #     data-id={@id}
  #     style={"transform: rotate(#{@rotation}deg) scale(0.95)"}
  #   >
  #     <% image =
  #       case @move_status do
  #         :valid -> "/images/tile_valid.png"
  #         :no_neighbours -> "/images/tile_dragging.png"
  #         :on_top -> "/images/tile_invalid.png"
  #         :invalid_top -> "/images/tile_invalid.png"
  #         :invalid_bottom -> "/images/tile_invalid.png"
  #         :invalid_left -> "/images/tile_invalid.png"
  #         :invalid_right -> "/images/tile_invalid.png"
  #         :invalid_neighbours -> "/images/tile_invalid.png"
  #         _ -> "/images/tile_default.png"
  #       end %>

  #     <img
  #       src={image}
  #       class={"absolute inset-0 #{a == -1 && "rotate-180"} drop-shadow-xl"}
  #       width="100"
  #       height="86"
  #       alt=""
  #     />
  #     <%= if @show_labels != false do %>
  #       <span class="absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 z-10 bg-white rounded-md px-1 whitespace-nowrap text-xs">
  #         <%= Enum.map(@value, fn x ->
  #           case x do
  #             -1 -> "."
  #             _ -> x
  #           end
  #         end)
  #         |> Enum.join("") %>
  #       </span>
  #       <.number :if={a > -1} value={a} class="absolute -translate-x-1/2 left-1/2 top-2.5" />
  #       <.number :if={b > -1} value={b} class="absolute -translate-x-full right-0 top-1" />
  #       <.number :if={c > -1} value={c} class="absolute -translate-x-full right-0 bottom-1" />
  #       <.number :if={d > -1} value={d} class="absolute -translate-x-1/2 left-1/2 bottom-2.5" />
  #       <.number :if={e > -1} value={e} class="absolute translate-x-full left-0 bottom-1" />
  #       <.number :if={f > -1} value={f} class="absolute translate-x-full left-0 top-1" />
  #     <% end %>
  #   </div>
  #   """
  # end

  # def number(assigns) do
  #   ~H"""
  #   <img src={"/images/number#{@value}.png"} class={@class} width="12" height="16" alt="" />
  #   """
  # end

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
