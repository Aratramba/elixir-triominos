defmodule TriominosWeb.Board do
  def validate(piece, %{"x" => x, "y" => y, "board" => board}) do
    pointing_up = Enum.at(piece.value, 0) == -1

    on_top = Enum.find(board, fn p -> p.x == x and p.y == y end)
    top_neighbour = Enum.find(board, fn p -> p.x == x and p.y == y - 1 end)
    bottom_neighbour = Enum.find(board, fn p -> p.x == x and p.y == y + 1 end)
    left_neighbour = Enum.find(board, fn p -> p.x == x - 1 and p.y == y end)
    right_neighbour = Enum.find(board, fn p -> p.x == x + 1 and p.y == y end)

    top_valid = validate_move("top", piece, top_neighbour)
    bottom_valid = validate_move("bottom", piece, bottom_neighbour)
    left_valid = validate_move("left", piece, left_neighbour)
    right_valid = validate_move("right", piece, right_neighbour)

    is_bridge = test_bridge(piece, board)

    has_neighbours = top_neighbour || bottom_neighbour || left_neighbour || right_neighbour

    has_only_bottom_neighbour =
      bottom_neighbour && pointing_up && !top_neighbour && !left_neighbour && !right_neighbour

    has_only_top_neighbour =
      top_neighbour && !pointing_up && !bottom_neighbour && !left_neighbour && !right_neighbour

    neighbours_valid = top_valid && bottom_valid && left_valid && right_valid

    cond do
      on_top -> {:on_top}
      has_only_bottom_neighbour -> {:invalid_bottom}
      has_only_top_neighbour -> {:invalid_top}
      !has_neighbours -> {:no_neighbours}
      !top_valid -> {:invalid_top}
      !bottom_valid -> {:invalid_bottom}
      !left_valid -> {:invalid_left}
      !right_valid -> {:invalid_right}
      !neighbours_valid -> {:invalid_neighbours}
      true -> {:valid}
    end
  end

  def validate_move("top", _piece, nil) do
    true
  end

  def validate_move("top", piece, neighbour) do
    [a, b, _c, _d, _e, f] = piece.value
    [a2, b2, c2, d2, e2, _f2] = neighbour.value

    rotation_ok = (a == -1 && a2 != -1) || (b == -1 && b2 != -1)
    match1 = f == e2 && f != -1
    match2 = b == c2 && b != -1
    match3 = a == d2 && a != -1

    rotation_ok && ((match1 && match2) || match3)
  end

  def validate_move("bottom", _piece, nil) do
    true
  end

  def validate_move("bottom", piece, neighbour) do
    [a, b, c, d, e, _f] = piece.value
    [a2, b2, _c2, _d2, _e2, f2] = neighbour.value

    rotation_ok = (a == -1 && a2 != -1) || (b == -1 && b2 != -1)
    match1 = e == f2 && e != -1
    match2 = c == b2 && c != -1
    match3 = d == a2 && d != -1

    rotation_ok && ((match1 && match2) || match3)
  end

  def validate_move("left", _piece, nil) do
    true
  end

  def validate_move("left", piece, neighbour) do
    [a, b, _c, d, e, f] = piece.value
    [a2, b2, c2, d2, _e2, _f2] = neighbour.value

    rotation_ok = (a == -1 && a2 != -1) || (b == -1 && b2 != -1)
    match1 = a == b2 && a != -1
    match2 = e == d2 && e != -1
    match3 = f == a2 && f != -1
    match4 = d == c2 && d != -1

    rotation_ok && ((match1 && match2) || (match3 && match4))
  end

  def validate_move("right", _piece, nil) do
    true
  end

  def validate_move("right", piece, neighbour) do
    [a, b, c, d, _e, _f] = piece.value
    [a2, b2, _c2, d2, e2, f2] = neighbour.value

    rotation_ok = (a == -1 && a2 != -1) || (b == -1 && b2 != -1)
    match1 = b == a2 && b != -1
    match2 = d == e2 && d != -1
    match3 = a == f2 && a != -1
    match4 = c == d2 && c != -1

    rotation_ok && ((match1 && match2) || (match3 && match4))
  end

  def test_bridge(piece, board) do
    [a, b, c, d, e, f] = piece.value

    # top bridge = no top neighbour, top left matches, top right matches
    # bottom bridge = no bottom neighbour, bottom left matches, bottom right matches
    # left bridge = no left neighbour, x-2_y+0 matches, x-1_y+1 matches
    # right bridge = no right neighbour, x+2_y+0 matches, x+1_y+0 matches

    # TODO: figure out all these for the rotated version as well

    {:ok}
  end
end
