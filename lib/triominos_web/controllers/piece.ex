defmodule TriominosWeb.Piece do
  defstruct id: nil, value: nil, x: nil, y: nil, rotation: 0

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

  TODO: perhaps shorten the notion to abcr notation
  """

  def new(id) do
    [a, b, c] = String.split(id, "", trim: true)
    value = [String.to_integer(a), -1, String.to_integer(b), -1, String.to_integer(c), -1]
    rotation = Enum.random(-5..5) / 10
    %__MODULE__{id: id, value: value, rotation: rotation}
  end

  @doc """
  Rotate a piece clockwise
  by moving the last value to the front
  """

  def rotate(item) do
    rotate(item, :cw)
  end

  def rotate(item, :cw) do
    [a, b, c, d, e, f] = item.value
    new_value = [f, a, b, c, d, e]
    %__MODULE__{item | value: new_value}
  end

  @doc """
  Rotate a piece counter clockwise
  by moving the first value to the back
  """

  def rotate(item, :ccw) do
    [a, b, c, d, e, f] = item.value
    new_value = [b, c, d, e, f, a]
    %__MODULE__{item | value: new_value}
  end

  def set_x(%__MODULE__{} = piece, x) do
    %__MODULE__{piece | x: x}
  end

  def set_y(%__MODULE__{} = piece, y) do
    %__MODULE__{piece | y: y}
  end
end
