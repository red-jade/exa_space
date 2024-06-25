defmodule Exa.Space.Pos2i do
  @moduledoc "A 2D position of integers."

  use Exa.Constants

  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @spec origin() :: S.pos2i()
  def origin(), do: {0, 0}

  # -----------
  # constructor
  # -----------

  @spec new(integer(), integer()) :: S.pos2i()
  def new(i, j) when is_integer(i) and is_integer(j), do: {i, j}

  # ---------
  # accessors
  # ---------

  @spec i(S.pos2i()) :: integer()
  def i({i, _}), do: i

  @spec j(S.pos2i()) :: integer()
  def j({_, j}), do: j

  # ----------------
  # public functions
  # ----------------

  @spec equals?(S.pos2i(), S.pos2i()) :: bool()
  def equals?(p1, p2), do: p1 == p2

  @spec move(S.pos2i(), S.vec2i()) :: S.pos2i()
  def move({i, j}, {di, dj}), do: {i + di, j + dj}

  @spec diff(S.pos2i(), S.pos2i()) :: S.vec2i()
  def diff({i1, j1}, {i2, j2}), do: {i2 - i1, j2 - j1}
end
