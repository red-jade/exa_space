defmodule Exa.Space.Vec2f do
  @moduledoc "A 2D vector."

  use Exa.Constants

  alias Exa.Math

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @doc "A zero vector."
  @spec zero() :: S.vec2f()
  def zero(), do: {0.0, 0.0}

  # ---------
  # accessors
  # ---------

  @doc "A unit vector in the x direction."
  @spec x_unit() :: S.vec2f()
  def x_unit(), do: {1.0, 0.0}

  @doc "A unit vector in the y direction."
  @spec y_unit() :: S.vec2f()
  def y_unit(), do: {0.0, 1.0}

  # -----------
  # constructor
  # -----------

  @doc "Create a vector from two nunmbers."
  @spec new(number(), number()) :: S.vec2f()
  def new(dx, dy) when is_float(dx) and is_float(dy), do: {dx, dy}
  def new(dx, dy) when is_number(dx) and is_number(dy), do: {1.0 * dx, 1.0 * dy}

  # ---------
  # accessors
  # ---------

  @doc "Get the dx component of the vector."
  @spec dx(S.vec2f()) :: float()
  def dx({dx, _}), do: dx

  @doc "Get the dy component of the vector."
  @spec dy(S.vec2f()) :: float()
  def dy({_, dy}), do: dy

  # --------------
  # public methods
  # --------------

  @doc "Test for a vector to be zero (within tolerance)."
  @spec zero?(S.vec2f(), E.epsilon()) :: bool()
  def zero?(v, eps \\ @epsilon)
  def zero?({0.0, 0.0}, _eps), do: true
  def zero?(v, eps) when is_vec2f(v) and is_eps(eps), do: len(v) < eps

  @doc "Test for a vector to be a unit vector, length 1.0 (within tolerance)."
  @spec unit?(S.vec2f(), E.epsilon()) :: bool()
  def unit?(v, e \\ @epsilon)
  def unit?({1.0, 0.0}, _eps), do: true
  def unit?({0.0, 1.0}, _eps), do: true
  def unit?(v, eps) when is_vec2f(v) and is_eps(eps), do: Math.equals?(len(v), 1.0, eps)

  @doc "Test two vectors for equality (within tolerance)."
  @spec equals?(S.vec2f(), S.vec2f(), E.epsilon()) :: bool()
  def equals?({dx1, dy1}, {dx2, dy2}, eps \\ @epsilon) do
    Math.equals?(dx1, dx2, eps) and Math.equals?(dy1, dy2, eps)
  end

  @doc "Get the length of the vector."
  @spec len(S.vec2f()) :: float()
  def len(v) when is_vec2f(v), do: :math.sqrt(dot(v, v))

  @doc """
  Normalize a vector so the result has length 1.0.

  The result will be Vec2F, or `:degenerate` 
  if the vector has zero length (within tolerance).
  """
  @spec norm(S.vec2f(), E.epsilon()) :: S.vec2f() | :degenerate
  def norm(v, eps \\ @epsilon) when is_vec2f(v) and is_eps(eps) do
    len = len(v)

    cond do
      Math.zero?(len, eps) -> :degenerate
      true -> mul(1.0 / len, v)
    end
  end

  @doc "Rotate anti-clockwise by 90 degrees. Same as 270 degrees clockwise."
  @spec rot90(S.vec2f()) :: S.vec2f()
  def rot90({dx, dy}), do: {-dy, dx}

  @doc "Rotate anti-clockwise by 180 degrees. Same as `neg` reflection through origin."
  @spec rot180(S.vec2f()) :: S.vec2f()
  def rot180({dx, dy}), do: {-dx, -dy}

  @doc "Rotate anti-clockwise by 270 degrees. Same as 90 degrees clockwise."
  @spec rot270(S.vec2f()) :: S.vec2f()
  def rot270({dx, dy}), do: {dy, -dx}

  @doc "Negate the vector, Same as reflection through the origin."
  @spec neg(S.vec2f()) :: S.vec2f()
  def neg({dx, dy}), do: {-dx, -dy}

  @doc "Add two vectors."
  @spec add(S.vec2f(), S.vec2f()) :: S.vec2f()
  def add({dx1, dy1}, {dx2, dy2}), do: {dx1 + dx2, dy1 + dy2}

  @doc "Subtract two vectors."
  @spec sub(S.vec2f(), S.vec2f()) :: S.vec2f()
  def sub({dx1, dy1}, {dx2, dy2}), do: {dx1 - dx2, dy1 - dy2}

  @doc "Scalar multiplication of a vector."
  @spec mul(float(), S.vec2f()) :: S.vec2f()
  def mul(p, {dx, dy}), do: {p * dx, p * dy}

  @doc "Dot product of two vectors."
  @spec dot(S.vec2f(), S.vec2f()) :: float()
  def dot({dx1, dy1}, {dx2, dy2}), do: dx1 * dx2 + dy1 * dy2

  @doc """
  The 2D cross product gives the scalar component 
  perpendicular to the 2D plane.
  """
  @spec cross(S.vec2f(), S.vec2f()) :: float()
  def cross({dx1, dy1}, {dx2, dy2}), do: dx1 * dy2 - dy1 * dx2

  @doc """
  Get the unsigned angle between two vectors. 

  The result is in the range [0, 180] degrees.

  Result `:degenerate` means one or more vectors
  has zero length.
  """
  @spec angle_deg(S.vec2f(), S.vec2f(), E.epsilon()) :: E.degrees() | :degenerate
  def angle_deg(v1, v2, eps \\ @epsilon) do
    l1 = len(v1)
    l2 = len(v2)

    cond do
      Math.zero?(l1, eps) -> :degenerate
      Math.zero?(l2, eps) -> :degenerate
      true -> Math.acosd(dot(v1, v2) / (l1 * l2))
    end
  end

  @doc """
  Get the orientation and signed angle between the vectors. 

  The angle result is in the range (-180, 180] degrees.

  Return the orientation and signed angle:
  - `:degenerate` means one or more sides has zero length (within tolerance)
  - `{:ccw, theta}` will be +ve angle theta.
  - `{:cw, theta}` will be -ve angle theta.
  - `{:degenerate, theta}` means the vectors are parallel
    and theta will be `0.0` or `180.0` (within tolerance).

  The angle return value will be in the range `(-180.0, 180.0]`.
  """
  @spec angle_deg_sign(S.vec2f(), S.vec2f(), E.epsilon()) ::
          {S.orientation(), E.degrees()} | :degenerate
  def angle_deg_sign(v1, v2, eps \\ @epsilon) when is_vec2f(v1) and is_vec2f(v2) do
    case angle_deg(v1, v2, eps) do
      :degenerate ->
        :degenerate

      theta ->
        case Math.sgn(cross(v1, v2)) do
          0 -> {:degenerate, theta}
          1 -> {:ccw, theta}
          -1 -> {:cw, -theta}
        end
    end
  end

  @doc """
  Get the orientation of two vectors.

  Result `:degenerate` means one or more vectors
  has zero length, or the vectors are parallel
  (original points collinear).
  """
  @spec orientation(S.vec2f(), S.vec2f(), E.epsilon()) :: S.orientation()
  def orientation(v1, v2, eps \\ @epsilon) when is_vec2f(v1) and is_vec2f(v2) do
    cross = cross(v1, v2)

    cond do
      Math.zero?(cross, eps) -> :degenerate
      cross > 0.0 -> :ccw
      true -> :cw
    end
  end

  @doc "Test if the two vectors are orthogonal (within tolerance)."
  @spec ortho?(S.vec2f(), S.vec2f(), E.epsilon()) :: bool() | :degenerate
  def ortho?(v1, v2, eps \\ @epsilon) when is_vec2f(v1) and is_vec2f(v2) do
    l1 = len(v1)
    l2 = len(v2)
    # note scaling affects zero? comparison here...
    cond do
      Math.zero?(l1, eps) -> :degenerate
      Math.zero?(l2, eps) -> :degenerate
      true -> Math.zero?(dot(v1, v2) / (l1 * l2), eps)
    end
  end

  @doc "Test if the two vectors are parallel (within tolerance)."
  @spec para?(S.vec2f(), S.vec2f(), E.epsilon()) :: bool() | :degenerate
  def para?(v1, v2, eps \\ @epsilon) do
    l1 = len(v1)
    l2 = len(v2)
    # note scaling affects zero? comparison here...
    cond do
      Math.zero?(l1, eps) -> :degenerate
      Math.zero?(l2, eps) -> :degenerate
      true -> Math.zero?(cross(v1, v2) / (l1 * l2), eps)
    end
  end

  @doc """
  Add/move a point by a vector.

  The name is taken from `Pos2f.move` with reversed arguments.
  The function is the same as `Vec2f.add`.
  The args are reversed to allow piping 
  from a vector chain to be added to a point.
  """
  @spec move(vec :: S.vec2f(), pos :: S.pos2f()) :: S.vec2f()
  def move({dx, dy}, {x, y}), do: {x + dx, y + dy}
end
