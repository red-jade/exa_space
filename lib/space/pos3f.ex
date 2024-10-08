defmodule Exa.Gfx.Space.Pos3f do
  @moduledoc "A 3D position."

  use Exa.Constants

  alias Exa.Math

  alias Exa.Types, as: E
  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @doc "The 3D float origin zero point."
  @spec origin() :: S.pos3f()
  def origin(), do: {0.0, 0.0, 0.0}

  # -----------
  # constructor
  # -----------

  @doc "Create a new 3D float position from 3 numbers."
  @spec new(number(), number(), number()) :: S.pos3f()

  def new(x, y, z) when is_float(x) and is_float(y) and is_float(z),
    do: {x, y, z}

  def new(x, y, z) when is_number(x) and is_number(y) and is_number(z),
    do: {1.0 * x, 1.0 * y, 1.0 * z}

  # ---------
  # accessors
  # ---------

  @doc "Get the x coordinate."
  @spec x(S.pos3f()) :: float()
  def x({x, _, _}), do: x

  @doc "Get the y coordinate."
  @spec y(S.pos3f()) :: float()
  def y({_, y, _}), do: y

  @doc "Get the z coordinate."
  @spec z(S.pos3f()) :: float()
  def z({_, _, z}), do: z

  # ----------------
  # public functions
  # ----------------

  @doc "Compare two points for equality (within tolerance)."
  @spec equals?(S.pos3f(), S.pos3f(), E.epsilon()) :: bool()
  def equals?({x1, y1, z1}, {x2, y2, z2}, eps \\ @epsilon) do
    Math.equals?(x1, x2, eps) and Math.equals?(y1, y2, eps) and Math.equals?(z1, z2, eps)
  end

  @doc "Move a point by a vector."
  @spec move(pos :: S.pos3f(), vec :: S.vec3f()) :: S.pos3f()
  def move({x, y, z}, {dx, dy, dz}), do: {x + dx, y + dy, z + dz}

  @doc "Get the vector between two points (P2 - P1)."
  @spec diff(p1 :: S.pos3f(), p2 :: S.pos3f()) :: S.vec3f()
  def diff({x1, y1, z1}, {x2, y2, z2}), do: {x2 - x1, y2 - y1, z2 - z1}
end
