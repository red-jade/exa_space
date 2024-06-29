defmodule Exa.Space.Pos2f do
  @moduledoc "A 2D position specified with floats."

  use Exa.Constants

  alias Exa.Types, as: E

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  alias Exa.Math
  alias Exa.Space.Vec2f

  # ---------
  # constants
  # ---------

  @doc "The 2D float origin zero point."
  @spec origin() :: S.pos2f()
  def origin(), do: {0.0, 0.0}

  # -----------
  # constructor
  # -----------

  @doc "Create a new 2D point from number coordinates."
  @spec new(number(), number()) :: S.pos2f()
  def new(x, y) when is_float(x) and is_float(y), do: {x, y}
  def new(x, y) when is_number(x) and is_number(y), do: {1.0 * x, 1.0 * y}

  # ---------
  # accessors
  # ---------

  @doc "Get the x coordinate."
  @spec x(S.pos2f()) :: float()
  def x({x, _}), do: x

  @doc "Get the y coordinate."
  @spec y(S.pos2f()) :: float()
  def y({_, y}), do: y

  # --------------
  # public methods
  # --------------

  @doc "Compare two points for equality (within tolerance)."
  @spec equals?(S.pos2f(), S.pos2f(), E.epsilon()) :: bool()
  def equals?({x1, y1}, {x2, y2}, eps \\ @epsilon) do
    Math.equals?(x1, x2, eps) and Math.equals?(y1, y2, eps)
  end

  @doc """
  Move a point by a vector.
  Add the vector to the point: P + V.
  """
  @spec move(pos :: S.pos2f(), vec :: S.vec2f()) :: S.pos2f()
  def move({x, y}, {dx, dy}), do: {x + dx, y + dy}

  @doc """
  The vector from P1 to P2.
  The vector difference: P2 - P1.
  """
  @spec diff(p1 :: S.pos2f(), p2 :: S.pos2f()) :: S.vec2f()
  def diff({x1, y1}, {x2, y2}), do: {x2 - x1, y2 - y1}

  @doc "Get the distance between two points: |P1 - P2| "
  @spec distance(S.pos2f(), S.pos2f()) :: float()
  def distance(p1, p2), do: p1 |> diff(p2) |> Vec2f.len()

  @doc """
  Get the intermediate point for parameter `t`.
  Linear interpolation: P1 + t * (P2-P1)

  Note that the ray formulation is more optimized for 
  calculating multiple interpolated points,
  because the ray (difference vector) is precalculated.
  """
  @spec lerp(S.pos2f(), E.param(), S.pos2f()) :: S.pos2f()
  def lerp(p1, t, p2) when is_pos2f(p1) and is_pos2f(p2) and is_float(t) do
    move(p1, Vec2f.mul(t, diff(p1, p2)))
  end
end
