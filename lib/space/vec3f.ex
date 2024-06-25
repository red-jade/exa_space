defmodule Exa.Space.Vec3f do
  @moduledoc "A 3D vector."

  use Exa.Constants

  alias Exa.Math

  import Exa.Types
  alias Exa.Types, as: E

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  # ---------
  # constants
  # ---------

  @spec zero() :: S.vec3f()
  def zero(), do: {0.0, 0.0, 0.0}

  @spec x_unit() :: S.vec3f()
  def x_unit(), do: {1.0, 0.0, 0.0}

  @spec y_unit() :: S.vec3f()
  def y_unit(), do: {0.0, 1.0, 0.0}

  @spec z_unit() :: S.vec3f()
  def z_unit(), do: {0.0, 0.0, 1.0}

  # -----------
  # constructor
  # -----------

  @spec new(number(), number(), number()) :: S.vec3f()

  def new(dx, dy, dz) when is_float(dx) and is_float(dy) and is_float(dz),
    do: {dx, dy, dz}

  def new(dx, dy, dz) when is_number(dx) and is_number(dy) and is_number(dz),
    do: {1.0 * dx, 1.0 * dy, 1.0 * dz}

  # ---------
  # accessors
  # ---------

  @spec dx(S.vec3f()) :: float()
  def dx({dx, _, _}), do: dx

  @spec dy(S.vec3f()) :: float()
  def dy({_, dy, _}), do: dy

  @spec dz(S.vec3f()) :: float()
  def dz({_, _, dz}), do: dz

  # --------------
  # public methods
  # --------------

  @spec zero?(S.vec3f(), E.epsilon()) :: bool()
  def zero?(v, eps \\ @epsilon)
  def zero?({0.0, 0.0, 0.0}, _eps), do: true
  def zero?(v, eps) when is_vec3f(v) and is_eps(eps), do: len(v) < eps

  @spec unit?(S.vec3f(), E.epsilon()) :: bool()
  def unit?(v, e \\ @epsilon)
  def unit?({1.0, 0.0, 0.0}, _eps), do: true
  def unit?({0.0, 1.0, 0.0}, _eps), do: true
  def unit?({0.0, 0.0, 1.0}, _eps), do: true
  def unit?(v, eps) when is_vec3f(v) and is_eps(eps), do: Math.equals?(len(v), 1.0, eps)

  @spec equals?(S.vec3f(), S.vec3f(), E.epsilon()) :: bool()
  def equals?({dx1, dy1, dz1}, {dx2, dy2, dz2}, eps \\ @epsilon) do
    Math.equals?(dx1, dx2, eps) and Math.equals?(dy1, dy2, eps) and Math.equals?(dz1, dz2, eps)
  end

  @spec len(S.vec3f()) :: float()
  def len(v) when is_vec3f(v), do: :math.sqrt(dot(v, v))

  @spec norm(S.vec3f(), E.epsilon()) :: S.vec3f()
  def norm(v, eps \\ @epsilon) when is_vec3f(v) and is_eps(eps) do
    len = len(v)

    if len < eps do
      raise ArgumentError, message: "Zero length vector #{v}"
    end

    mul(1.0 / len, v)
  end

  @spec neg(S.vec3f()) :: S.vec3f()
  def neg({dx, dy, dz}), do: {-dx, -dy, -dz}

  @spec add(S.vec3f(), S.vec3f()) :: S.vec3f()
  def add({dx1, dy1, dz1}, {dx2, dy2, dz2}), do: {dx1 + dx2, dy1 + dy2, dz1 + dz2}

  @spec sub(S.vec3f(), S.vec3f()) :: S.vec3f()
  def sub({dx1, dy1, dz1}, {dx2, dy2, dz2}), do: {dx1 - dx2, dy1 - dy2, dz1 - dz2}

  @spec mul(float(), S.vec3f()) :: S.vec3f()
  def mul(p, {dx, dy, dz}), do: {p * dx, p * dy, p * dz}

  @spec dot(S.vec3f(), S.vec3f()) :: float()
  def dot({dx1, dy1, dz1}, {dx2, dy2, dz2}), do: dx1 * dx2 + dy1 * dy2 + dz1 * dz2

  @spec cross(S.vec3f(), S.vec3f()) :: S.vec3f()
  def cross({dx1, dy1, dz1}, {dx2, dy2, dz2}) do
    {dy1 * dz2 - dz1 * dy2, dz1 * dx2 - dx1 * dz2, dx1 * dy2 - dy1 * dx2}
  end

  @spec ortho?(S.vec3f(), S.vec3f(), E.epsilon()) :: bool()
  def ortho?(a, b, eps \\ @epsilon), do: dot(a, b) < eps

  @spec para?(S.vec3f(), S.vec3f(), E.epsilon()) :: bool()
  def para?(a, b, eps \\ @epsilon), do: len(cross(a, b)) < eps
end
