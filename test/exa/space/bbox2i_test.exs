defmodule Exa.Space.BBox2iTest do
  use ExUnit.Case

  import Exa.Space.BBox2i

  test "simple" do
    {:ok, a} = new(1, 2, 8, 9)
    assert {1, 2, 8, 9} == a
    assert {{1, 2}, {8, 8}} = to_pos_dims(a)
    assert a == from_pos_dims({1, 2}, {8, 8})
    assert 64 == area(a)

    assert {:ok, {1, 2, 1, 9}} == new(1, 2, 1, 9)
    assert :error == new(1, 2, 0, 9)
    assert :error == new(1, 2, 8, 1)

    {:ok, b} = new(10, 20, 50, 60)

    assert {{10, 20}, {41, 41}} = to_pos_dims(b)
    assert b == from_pos_dims({10, 20}, {41, 41})
    assert 1681 == area(b)

    assert :error == new(10, 20, 5, 60)
    assert :error == new(10, 20, 50, 10)
  end

  test "inside" do
    {:ok, a} = new(2, 3, 4, 5)

    assert :outside != classify(a, {3, 4})
    assert :on_point == classify(a, {2, 3})
    assert :on_edge == classify(a, {2, 4})
    assert :outside == classify(a, {1, 9})
  end

  test "union intersection" do
    {:ok, a} = new(2, 3, 4, 5)
    {:ok, b} = new(3, 2, 5, 4)

    assert {2, 2, 5, 5} == union(a, b)

    assert {:ok, {3, 3, 4, 4}} == intersect(a, b)

    {:ok, c} = new(0, 0, 9, 9)
    assert {:ok, a} == intersect(a, c)
    assert {:ok, b} == intersect(b, c)
  end
end
