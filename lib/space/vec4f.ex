defmodule Exa.Space.Vec4f do
  @moduledoc """
  A 4D vector.

  Often used as 3D vector in homogeneous projective coordinates.
  See `Exa.Space.Xform` for more details.
  """

  # TODO - clarify Vec4f and Pos4f
  #        mostly use Pos4f for homo proj coord
  #        but need Vec4f for dot of vectors in Xform matrices !?

  use Exa.Constants

  alias Exa.Types, as: E
  alias Exa.Space.Types, as: S

  alias Exa.Math

  # -----------
  # constructor
  # -----------

  @doc "Create new 4D vector (3D homogeneous point)."
  @spec new(float(), float(), float(), float()) :: S.vec4f()
  def new(dx, dy, dz, dw) when is_float(dx) and is_float(dy) and is_float(dz) and is_float(dw) do
    {dx, dy, dz, dw}
  end

  # ---------
  # accessors
  # ---------

  @doc "Get the x component."
  @spec dx(S.vec4f()) :: float()
  def dx({dx, _, _, _}), do: dx

  @doc "Get the y component."
  @spec dy(S.vec4f()) :: float()
  def dy({_, dy, _, _}), do: dy

  @doc "Get the z component."
  @spec dz(S.vec4f()) :: float()
  def dz({_, _, dz, _}), do: dz

  @doc "Get the w projective component."
  @spec dw(S.vec4f()) :: float()
  def dw({_, _, _, dw}), do: dw

  # --------------
  # public methods
  # --------------

  @doc "Compare two vectors for equality (within tolerance)."
  @spec equals?(S.vec4f(), S.vec4f(), E.epsilon()) :: bool()
  def equals?({dx1, dy1, dz1, dw1}, {dx2, dy2, dz2, dw2}, eps \\ @epsilon) do
    Math.equals?(dx1, dx2, eps) and Math.equals?(dy1, dy2, eps) and
      Math.equals?(dz1, dz2, eps) and Math.equals?(dw1, dw2, eps)
  end

  @doc "Negate a vector."
  @spec neg(S.vec4f()) :: S.vec4f()
  def neg({dx, dy, dz, dw}),
    do: {-dx, -dy, -dz, -dw}

  @doc "Add two vectors."
  @spec add(S.vec4f(), S.vec4f()) :: S.vec4f()
  def add({dx1, dy1, dz1, dw1}, {dx2, dy2, dz2, dw2}),
    do: {dx1 + dx2, dy1 + dy2, dz1 + dz2, dw1 + dw2}

  @doc "Subtract two vectors."
  @spec sub(S.vec4f(), S.vec4f()) :: S.vec4f()
  def sub({dx1, dy1, dz1, dw1}, {dx2, dy2, dz2, dw2}),
    do: {dx1 - dx2, dy1 - dy2, dz1 - dz2, dw1 - dw2}

  @doc "Scalar multiplication by a float."
  @spec mul(float(), S.vec4f()) :: S.vec4f()
  def mul(p, {dx, dy, dz, dw}),
    do: {p * dx, p * dy, p * dz, p * dw}

  @doc "Dot product."
  @spec dot(S.vec4f(), S.vec4f()) :: float()
  def dot({dx1, dy1, dz1, dw1}, {dx2, dy2, dz2, dw2}),
    do: dx1 * dx2 + dy1 * dy2 + dz1 * dz2 + dw1 * dw2
end
