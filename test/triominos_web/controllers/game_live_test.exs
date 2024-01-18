defmodule TriominosWeb.GameLiveTest do
  alias TriominosWeb.Piece
  use TriominosWeb.ConnCase

  # test "GET /", %{conn: conn} do
  #   conn = get(conn, ~p"/")
  #   assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  # end

  test "new" do
    piece = Piece.new("123")
    assert piece.value == [1, -1, 2, -1, 3, -1]
  end

  test "rotate" do
    piece = Piece.new("123")

    piece = Piece.rotate(piece)
    assert piece.value == [-1, 1, -1, 2, -1, 3]

    piece = Piece.rotate(piece)
    assert piece.value == [3, -1, 1, -1, 2, -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, 3, -1, 1, -1, 2]

    piece = Piece.rotate(piece)
    assert piece.value == [2, -1, 3, -1, 1, -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, 2, -1, 3, -1, 1]

    piece = Piece.rotate(piece)
    assert piece.value == [1, -1, 2, -1, 3, -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, 1, -1, 2, -1, 3]
  end

  test "validate initial piece" do
    piece_2 = Piece.new("002") |> Piece.set_x(10) |> Piece.set_y(10)
    board = [piece_2]

    piece = Piece.new("022")

    # no neighbours
    assert TriominosWeb.GameLive.validate(piece, %{"x" => 12, "y" => 12, "board" => board}) ==
             {:no_neighbours}

    # on top
    assert TriominosWeb.GameLive.validate(piece, %{"x" => 10, "y" => 10, "board" => board}) ==
             {:on_top}

    # on top rotated
    assert TriominosWeb.GameLive.validate(piece |> Piece.rotate(), %{
             "x" => 10,
             "y" => 10,
             "board" => board
           }) ==
             {:on_top}

    # below not rotated
    assert TriominosWeb.GameLive.validate(piece, %{
             "x" => 10,
             "y" => 11,
             "board" => board
           }) ==
             {:invalid_top}

    # below once rotated
    assert TriominosWeb.GameLive.validate(piece |> Piece.rotate(), %{
             "x" => 10,
             "y" => 11,
             "board" => board
           }) ==
             {:valid}

    # above not rotated
    assert TriominosWeb.GameLive.validate(piece, %{
             "x" => 10,
             "y" => 9,
             "board" => board
           }) ==
             {:invalid_bottom}

    # above once rotated
    assert TriominosWeb.GameLive.validate(piece |> Piece.rotate(), %{
             "x" => 10,
             "y" => 9,
             "board" => board
           }) ==
             {:invalid_bottom}

    # right not rotated
    assert TriominosWeb.GameLive.validate(piece, %{
             "x" => 11,
             "y" => 10,
             "board" => board
           }) ==
             {:invalid_left}

    # right once rotated
    assert TriominosWeb.GameLive.validate(piece |> Piece.rotate(), %{
             "x" => 11,
             "y" => 10,
             "board" => board
           }) ==
             {:invalid_left}

    # left not rotated
    assert TriominosWeb.GameLive.validate(piece, %{
             "x" => 9,
             "y" => 10,
             "board" => board
           }) ==
             {:invalid_right}

    # left once rotated
    assert TriominosWeb.GameLive.validate(piece |> Piece.rotate(), %{
             "x" => 9,
             "y" => 10,
             "board" => board
           }) ==
             {:valid}
  end
end
