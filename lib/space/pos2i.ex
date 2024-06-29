defmodule Exa.Space.Pos2i do
  @moduledoc "A 2D position of integers."

  use Exa.Constants

  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @doc "The 2D integer origin zero point."
  @spec origin() :: S.pos2i()
  def origin(), do: {0, 0}

  # -----------
  # constructor
  # -----------

  @doc "Create a new 2D integer point from two numbers."
  @spec new(integer(), integer()) :: S.pos2i()
  def new(i, j) when is_integer(i) and is_integer(j), do: {i, j}

  # ---------
  # accessors
  # ---------

  @doc "Get the i coordinate."
  @spec i(S.pos2i()) :: integer()
  def i({i, _}), do: i

  @doc "Get the j coordinate."
  @spec j(S.pos2i()) :: integer()
  def j({_, j}), do: j

  # ----------------
  # public functions
  # ----------------

  @doc """
  Move a point by a vector.
  Add the vector to the point: P + V.
  """
  @spec move(pos :: S.pos2i(), vec :: S.vec2i()) :: S.pos2i()
  def move({i, j}, {di, dj}), do: {i + di, j + dj}

  @doc """
  The vector from P1 to P2.
  The vector difference: P2 - P1.
  """
  @spec diff(p1 :: S.pos2i(), p2 :: S.pos2i()) :: S.vec2i()
  def diff({i1, j1}, {i2, j2}), do: {i2 - i1, j2 - j1}
end
