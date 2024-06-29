defmodule Exa.Space.Pos3i do
  @moduledoc "A 3D position of integers."

  use Exa.Constants

  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @doc "The 3D integer origin zero point."
  @spec origin() :: S.pos3i()
  def origin(), do: {0, 0, 0}

  # -----------
  # constructor
  # -----------

  @doc "Create a new 3D integer point from three numbers."
  @spec new(integer(), integer(), integer()) :: S.pos3i()
  def new(i, j, k) when is_integer(i) and is_integer(j) and is_integer(k), do: {i, j, k}

  # ---------
  # accessors
  # ---------

  @doc "Get the i coordinate."
  @spec i(S.pos3i()) :: integer()
  def i({i, _, _}), do: i

  @doc "Get the j coordinate."
  @spec j(S.pos3i()) :: integer()
  def j({_, j, _}), do: j

  @doc "Get the k coordinate."
  @spec k(S.pos3i()) :: integer()
  def k({_, _, k}), do: k

  # ----------------
  # public functions
  # ----------------

  # TODO - Vec3i

  @doc "Move a point by a vector: P + V"
  @spec move(pos :: S.pos3i(), vec :: {integer(), integer(), integer()}) :: S.pos3i()
  def move({i, j, k}, {di, dj, dk}), do: {i + di, j + dj, k + dk}

  @doc "Calculate the vector from P1 to P2. The vector P2 - P1."
  @spec diff(S.pos3i(), S.pos3i()) :: {integer(), integer(), integer()}
  def diff({i1, j1, k1}, {i2, j2, k2}), do: {i2 - i1, j2 - j1, k2 - k1}
end
