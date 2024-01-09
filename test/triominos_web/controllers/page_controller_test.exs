defmodule TriominosWeb.PageControllerTest do
  use TriominosWeb.ConnCase
  alias TriominosWeb.Piece

  # test "GET /", %{conn: conn} do
  #   conn = get(conn, ~p"/")
  #   assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  # end

  test "new" do
    piece = Piece.new("123")
    assert piece.value == ["1", -1, "2", -1, "3", -1]
  end

  test "rotate" do
    piece = Piece.new("123")

    piece = Piece.rotate(piece)
    assert piece.value == [-1, "1", -1, "2", -1, "3"]

    piece = Piece.rotate(piece)
    assert piece.value == ["3", -1, "1", -1, "2", -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, "3", -1, "1", -1, "2"]

    piece = Piece.rotate(piece)
    assert piece.value == ["2", -1, "3", -1, "1", -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, "2", -1, "3", -1, "1"]

    piece = Piece.rotate(piece)
    assert piece.value == ["1", -1, "2", -1, "3", -1]

    piece = Piece.rotate(piece)
    assert piece.value == [-1, "1", -1, "2", -1, "3"]
  end

  test "validate" do
    piece = Piece.new("123")
    piece_2 = Piece.new("012")
    piece_3 = Piece.new("111")
    piece_4 = Piece.new("222")

    board = [piece, piece_2, piece_3, piece_4]

    assert Piece.validate(piece, board) == true
  end
end
