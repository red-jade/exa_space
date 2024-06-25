defmodule Exa.Space.BBox2fTest do
  use ExUnit.Case

  import Exa.Space.BBox2f

  # small non-zero value less than the default @epsilon
  @del 1.0e-7

  test "simple" do
    {:ok, a} = new(0.1, 0.2, 0.8, 0.9)
    assert {0.1, 0.2, 0.8, 0.9} == a

    assert 0.49 == area(a)

    assert :degenerate == new(0.1, 0.2, 0.1, 0.9)
    assert :degenerate == new(0.1, 0.2, 0.8, 0.2)

    assert :degenerate == new(0.1, 0.2, 0.1 + @del, 0.9)
    assert :degenerate == new(0.1, 0.2, 0.8, 0.2 + @del)

    assert :error == new(0.1, 0.2, 0.099, 0.9)
    assert :error == new(0.1, 0.2, 0.8, 0.199)

    {:ok, b} = from_ints(10, 20, 50, 60)
    assert {10.0, 20.0, 50.0, 60.0} == b

    assert 1600.0 == area(b)

    assert :degenerate == from_ints(10, 20, 10, 600)
    assert :degenerate == from_ints(10, 20, 50, 20)

    assert :error == from_ints(10, 20, 5, 60)
    assert :error == from_ints(10, 20, 50, 10)
  end

  test "mid w h" do
    {:ok, a} = new(0.1, 0.2, 0.8, 0.9)
    assert {{0.1, 0.2}, {0.7000000000000001, 0.7}} = to_pos_dims(a)
    assert {{0.45, 0.55}, {0.7000000000000001, 0.7}} = to_center_dims(a)
  end

  test "inside" do
    {:ok, a} = new(2.0, 3.0, 4.0, 5.0)

    assert :inside == classify(a, {3.0, 4.0})

    assert :on_point == classify(a, {2.0, 3.0})
    assert :on_point == classify(a, {2.0 - @del, 3.0})
    assert :on_point == classify(a, {2.0, 3.0 + @del})

    assert :on_edge == classify(a, {2.0, 4.0})
    assert :on_edge == classify(a, {2.0 + @del, 4.0})
    assert :on_edge == classify(a, {2.0, 4.0 - @del})

    assert :outside == classify(a, {1.0, 9.0})
  end

  test "union intersection" do
    {:ok, a} = new(2.0, 3.0, 4.0, 5.0)
    {:ok, b} = new(3.0, 2.0, 5.0, 4.0)

    assert {2.0, 2.0, 5.0, 5.0} == union(a, b)

    assert {:ok, {3.0, 3.0, 4.0, 4.0}} == intersect(a, b)

    {:ok, c} = new(0.0, 0.0, 9.0, 9.0)
    assert {:ok, a} == intersect(a, c)
    assert {:ok, b} == intersect(b, c)
  end
end
