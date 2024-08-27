defmodule Exa.Space.XformTest do
  use ExUnit.Case

  import Exa.Space.Xform

  alias Exa.Space.Vec3f
  alias Exa.Space.Vec2f

  test "simple 2x2" do
    i2 = new22(2, 1, 7, 4)
    assert {2.0, 1.0, 7.0, 4.0} = i2
    assert {2.0, 7.0, 1.0, 4.0} = transpose(i2)

    assert 6.0 = trace(i2)
    assert 1.0 = det(i2)

    inv2 = inv(i2)
    assert {4.0, -1.0, -7.0, 2.0} = inv2

    prod2 = multiply(inv2, i2)
    assert equals?(:iden22, prod2)
  end

  test "simple 3x3" do
    i3 = new33(2, 1, 7, 4, 3, 6, 2, 1, 8)
    assert {2.0, 1.0, 7.0, 4.0, 3.0, 6.0, 2.0, 1.0, 8.0} = i3
    assert {2.0, 4.0, 2.0, 1.0, 3.0, 1.0, 7.0, 6.0, 8.0} = transpose(i3)

    assert 13.0 = trace(i3)
    assert 2.0 = det(i3)

    inv3 = inv(i3)
    assert {9.0, -0.5, -7.5, -10.0, 1.0, 8.0, -1.0, 0.0, 1.0} == inv3

    prod3 = multiply(inv3, i3)
    assert equals?(:iden33, prod3)
  end

  test "apply 2x2" do
    m22 = new22(2, 1, 7, 4)
    v2 = Vec2f.new(1, -2)
    assert {0.0, -1.0} == xform(m22, v2)
  end

  test "apply 3x3" do
    m33 = new33(2, 1, 7, 4, 3, 6, 2, 1, 8)
    v3 = Vec3f.new(1, 2, -1)
    assert {-3.0, 4.0, -4.0} = xform(m33, v3)
  end
end
