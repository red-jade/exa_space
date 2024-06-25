defmodule Exa.Space.Pos3i do
  @moduledoc "A 3D position of integers."

  use Exa.Constants

  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @spec origin() :: S.pos3i()
  def origin(), do: {0, 0, 0}

  # -----------
  # constructor
  # -----------

  @spec new(integer(), integer(), integer()) :: S.pos3i()
  def new(i, j, k) when is_integer(i) and is_integer(j) and is_integer(k), do: {i, j, k}

  # ---------
  # accessors
  # ---------

  @spec i(S.pos3i()) :: integer()
  def i({i, _, _}), do: i

  @spec j(S.pos3i()) :: integer()
  def j({_, j, _}), do: j

  @spec k(S.pos3i()) :: integer()
  def k({_, _, k}), do: k

  # ----------------
  # public functions
  # ----------------

  @spec equals?(S.pos3i(), S.pos3i()) :: bool()
  def equals?(p1, p2), do: p1 == p2

  # TODO - Vec3i

  @spec move(S.pos3i(), {integer(), integer(), integer()}) :: S.pos3i()
  def move({i, j, k}, {di, dj, dk}), do: {i + di, j + dj, k + dk}

  # @spec diff(S.pos3i(), S.pos3i()) :: S.vec3i()
  # def diff({i1, j1, k1}, {i2, j2, k2}), do: {i2 - i1, j2 - j1, k2 - k1}
end
