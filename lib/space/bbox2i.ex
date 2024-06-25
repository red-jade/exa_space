defmodule Exa.Space.BBox2i do
  @moduledoc "A 2D axis-aligned bounding box with integer coordinates."

  use Exa.Constants

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  alias Exa.Space.BBox1i

  @typedoc """
  A valid bounding box, or a reason for error:
  at least one of the min/max pairs has no overlap (non-positive area).
  """
  @type bbox2i_type() :: {:ok, S.bbox2i()} | :error

  # -----------
  # constructor
  # -----------

  @doc "Get the bounding box from bounding values."
  @spec new(integer(), integer(), integer(), integer()) :: bbox2i_type()
  def new(imin, jmin, imax, jmax)
      when is_integer(imin) and is_integer(jmin) and
             is_integer(imax) and is_integer(jmax) do
    cond do
      imin <= imax and jmin <= jmax -> {:ok, {imin, jmin, imax, jmax}}
      imin > imax or jmin > jmax -> :error
    end
  end

  @doc "Get the bounding box of point and width & height."
  @spec from_pos_dims(S.pos2i(), S.dim2()) :: S.bbox2i()
  def from_pos_dims({i, j} \\ {0, 0}, {w, h} = dims) when is_dim2(dims) do
    {i, j, i + w - 1, j + h - 1}
  end

  @doc "Get the bounding box of two points."
  @spec from_corners(S.pos2i(), S.pos2i()) :: S.bbox2i()
  def from_corners({i1, j1}, {i2, j2}) do
    {min(i1, i2), min(j1, j2), max(i1, i2), max(j1, j2)}
  end

  @doc "Get the bounding box of a list of points."
  @spec from_coords(S.coords2i()) :: S.bbox2i()
  def from_coords([{i, j} | ps]) when ps != [] do
    Enum.reduce(ps, {i, j, i, j}, fn {i, j}, {imin, jmin, imax, jmax} ->
      {min(i, imin), min(j, jmin), max(i, imax), max(j, jmax)}
    end)
  end

  # ---------
  # accessors
  # ---------

  @spec imin(S.bbox2i()) :: integer()
  def imin({imin, _, _, _}), do: imin

  @spec jmin(S.bbox2i()) :: integer()
  def jmin({_, jmin, _, _}), do: jmin

  @spec imax(S.bbox2i()) :: integer()
  def imax({_, _, imax, _}), do: imax

  @spec jmax(S.bbox2i()) :: integer()
  def jmax({_, _, _, jmax}), do: jmax

  # --------------
  # public methods
  # --------------

  @doc "Get the integral area of the bounding box."
  @spec area(S.bbox2i()) :: integer()
  def area({imin, jmin, imax, jmax}), do: (imax - imin + 1) * (jmax - jmin + 1)

  @doc "Get the bounding box as point and width & height."
  @spec to_pos_dims(S.bbox2i()) :: {S.pos2i(), S.dim2()}
  def to_pos_dims({imin, jmin, imax, jmax}) do
    {{imin, jmin}, {imax - imin + 1, jmax - jmin + 1}}
  end

  @doc "Get the bounding box as two corner points."
  @spec to_pos2i(S.bbox2i()) :: {S.pos2i(), S.pos2i()}
  def to_pos2i({imin, jmin, imax, jmax}) do
    {{imin, jmin}, {imax, jmax}}
  end

  @doc "Get the bounding box that covers both the arguments."
  @spec union(S.bbox2i(), S.bbox2i()) :: S.bbox2i()
  def union({imin1, jmin1, imax1, jmax1}, {imin2, jmin2, imax2, jmax2}) do
    {min(imin1, imin2), min(jmin1, jmin2), max(imax1, imax2), max(jmax1, jmax2)}
  end

  @doc """
  Get the intersection of two bounding boxes, 
  or error if the intersection has no area.
  """
  @spec intersect(S.bbox2i(), S.bbox2i()) :: bbox2i_type()
  def intersect({imin1, jmin1, imax1, jmax1}, {imin2, jmin2, imax2, jmax2}) do
    new(max(imin1, imin2), max(jmin1, jmin2), min(imax1, imax2), min(jmax1, jmax2))
  end

  @doc "Test the relation of a point to the bounding box."
  @spec classify(S.bbox2i(), S.pos2i()) :: S.in_shape2d()
  def classify({imin, jmin, imax, jmax}, {i, j}) do
    # test values  :inside  :outside  :on_point
    itest = BBox1i.classify({imin, imax}, i)
    jtest = BBox1i.classify({jmin, jmax}, j)

    iin? = itest == :inside
    jin? = jtest == :inside

    iout? = itest == :outside
    jout? = jtest == :outside

    cond do
      iin? and jin? ->
        :inside

      iout? or jout? ->
        :outside

      true ->
        ieq = if itest == :on_point, do: 1, else: 0
        jeq = if jtest == :on_point, do: 1, else: 0

        case ieq + jeq do
          1 -> :on_edge
          2 -> :on_point
        end
    end
  end
end
