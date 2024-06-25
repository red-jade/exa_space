defmodule Exa.Space.Vec3fTest do
  use ExUnit.Case

  import Exa.Space.Vec3f

  test "simple" do
    assert zero?(zero())
    assert unit?(x_unit())
    assert unit?(y_unit())
    assert unit?(z_unit())

    a = new(0.1, 0.2, 0.3)
    b = new(1.2, 1.3, 1.4)

    assert {0.1, 0.2, 0.3} = a

    assert {1.3, 1.5, 1.7} = add(a, b)
    assert equals?({1.1, 1.1, 1.1}, sub(b, a))

    assert a = sub(a, zero())
    assert b = sub(b, zero())

    assert equals?({0.3, 0.6, 0.9}, mul(3.0, a))
    assert 0.80 = dot(a, b)

    assert para?(a, a)
    assert para?(b, b)

    assert unit?(norm(a))
    assert unit?(norm(b))

    c = cross(a, b)

    assert ortho?(a, c)
    assert ortho?(b, c)
  end
end
