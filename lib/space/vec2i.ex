defmodule Exa.Space.Vec2i do
  @moduledoc "A 2D vector of integers."

  use Exa.Constants

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  alias Exa.Space.Vec2f

  # ---------
  # constants
  # ---------

  @spec zero() :: S.vec2i()
  def zero(), do: {0, 0}

  @spec i_unit() :: S.vec2i()
  def i_unit(), do: {1, 0}

  @spec j_unit() :: S.vec2i()
  def j_unit(), do: {0, 1}

  # -----------
  # constructor
  # -----------

  @spec new(integer(), integer()) :: S.vec2i()
  def new(di, dj) when is_integer(di) and is_integer(dj), do: {di, dj}

  # ---------
  # accessors
  # ---------

  @spec di(S.vec2i()) :: integer()
  def di({di, _}), do: di

  @spec dj(S.vec2i()) :: integer()
  def dj({_, dj}), do: dj

  # ----------------
  # public functions
  # ----------------

  @spec zero?(S.vec2i()) :: bool()
  def zero?(v), do: v == {0, 0}

  @spec equals?(S.vec2i(), S.vec2i()) :: bool()
  def equals?(v1, v2) when is_vec2i(v1) and is_vec2i(v2), do: v1 == v2

  # Linear.length()
  @spec len(S.vec2i()) :: float()
  def len(v) when is_vec2i(v), do: :math.sqrt(dot(v, v))

  @doc """
  Normalize a vector so the result has length 1.0.
  The result is always Vec2f.
  """
  @spec norm(S.vec2i()) :: S.vec2f() | :degenerate
  def norm({di, dj} = v) when is_vec2i(v) do
    cond do
      zero?(v) -> :degenerate
      true -> Vec2f.mul(1.0 / len(v), Vec2f.new(di, dj))
    end
  end

  @doc "Rotate anti-clockwise by 90 degrees. Same as 270 degrees clockwise."
  @spec rot90(S.vec2i()) :: S.vec2i()
  def rot90({di, dj}), do: {-dj, di}

  @doc "Rotate anti-clockwise by 180 degrees. Same as `neg` reflection through origin."
  @spec rot180(S.vec2i()) :: S.vec2i()
  def rot180({di, dj}), do: {-di, -dj}

  @doc "Rotate anti-clockwise by 270 degrees. Same as 90 degrees clockwise."
  @spec rot270(S.vec2i()) :: S.vec2i()
  def rot270({di, dj}), do: {dj, -di}

  @doc "Negate the vector, Same as reflection through the origin."
  @spec neg(S.vec2i()) :: S.vec2i()
  def neg({di, dj}), do: {-di, -dj}

  @spec add(S.vec2i(), S.vec2i()) :: S.vec2i()
  def add({di1, dj1}, {di2, dj2}), do: {di1 + di2, dj1 + dj2}

  @spec sub(S.vec2i(), S.vec2i()) :: S.vec2i()
  def sub({di1, dj1}, {di2, dj2}), do: {di1 - di2, dj1 - dj2}

  @spec mul(float(), S.vec2i()) :: S.vec2i()
  def mul(p, {di, dj}), do: {p * di, p * dj}

  @spec dot(S.vec2i(), S.vec2i()) :: integer()
  def dot({di1, dj1}, {di2, dj2}), do: di1 * di2 + dj1 * dj2

  @doc """
  The 2D dot product gives the scalar component 
  perpendicular to the 2D plane.
  """
  @spec cross(S.vec2i(), S.vec2i()) :: integer()
  def cross({di1, dj1}, {di2, dj2}), do: di1 * dj2 - dj1 * di2

  @doc "Test if the two vectors are orthogonal."
  @spec ortho?(S.vec2i(), S.vec2i()) :: bool() | :degenerate
  def ortho?(v1, v2) when is_vec2i(v1) and is_vec2i(v2) do
    cond do
      zero?(v1) -> :degenerate
      zero?(v2) -> :degenerate
      true -> 0 == dot(v1, v2)
    end
  end

  @doc "Test if the two vectors are parallel (within tolerance)."
  @spec para?(S.vec2i(), S.vec2i()) :: bool() | :degenerate
  def para?(v1, v2) do
    cond do
      zero?(v1) -> :degenerate
      zero?(v2) -> :degenerate
      true -> 0 == cross(v1, v2)
    end
  end

  @doc """
  Add/move a point by a vector.

  The name is taken from `Pos2i.move` with reversed arguments.
  The function is the same as `Vec2i.add`.
  The args are reversed to allow piping 
  from a vector chain to be added to a point.
  """
  @spec move(S.vec2i(), S.pos2i()) :: S.vec2i()
  def move({di, dj}, {i, j}), do: {i + di, j + dj}
end
