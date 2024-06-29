defmodule Exa.Space.BBox3i do
  @moduledoc "A 3D axis-aligned bounding box with integer coordinates."

  use Exa.Constants

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  alias Exa.Space.BBox1i

  @typedoc """
  A valid bounding box, or a reason for error:
  at least one of the min/max pairs has no overlap (non-positive area).
  """
  @type bbox3i_type() :: {:ok, S.bbox3i()} | :error

  # -----------
  # constructor
  # -----------

  @doc "Get the bounding box from bounding values."
  @spec new(integer(), integer(), integer(), integer(), integer(), integer()) :: bbox3i_type()
  def new(imin, jmin, imax, jmax, kmin, kmax)
      when is_integer(imin) and is_integer(jmin) and
             is_integer(imax) and is_integer(jmax) and
             is_integer(kmax) and is_integer(kmax) do
    cond do
      imin <= imax and jmin <= jmax and kmin <= kmax -> {:ok, {imin, jmin, imax, jmax}}
      imin > imax or jmin > jmax or kmin > kmax -> :error
    end
  end

  @doc "Get the bounding box of point and width & height & depth."
  @spec from_pos_dims(S.pos3i(), S.dim3()) :: S.bbox3i()
  def from_pos_dims({i, j, k}, {idim, jdim, kdim} = dims) when is_dim3(dims) do
    {i, j, k, i + idim - 1, j + jdim - 1, k + kdim - 1}
  end

  @doc "Get the bounding box of two points."
  @spec from_corners(S.pos3i(), S.pos3i()) :: S.bbox3i()
  def from_corners({i1, j1, k1}, {i2, j2, k2}) do
    {min(i1, i2), min(j1, j2), min(k1, k2), max(i1, i2), max(j1, j2), max(k1, k2)}
  end

  @doc "Get the bounding box of a list of points."
  @spec from_coords(S.coords3i()) :: S.bbox3i()
  def from_coords([{i, j, k} | ps]) when ps != [] do
    Enum.reduce(ps, {i, j, k, i, j, k}, fn {i, j, k}, {imin, jmin, kmin, imax, jmax, kmax} ->
      {min(i, imin), min(j, jmin), min(k, kmin), max(i, imax), max(j, jmax), max(k, kmax)}
    end)
  end

  # ---------
  # accessors
  # ---------

  @doc "Get the minimum i value."
  @spec imin(S.bbox3i()) :: integer()
  def imin({imin, _, _, _, _, _}), do: imin

  @doc "Get the minimum j value."
  @spec jmin(S.bbox3i()) :: integer()
  def jmin({_, jmin, _, _, _, _}), do: jmin

  @doc "Get the minimum k value."
  @spec kmin(S.bbox3i()) :: integer()
  def kmin({_, _, kmin, _, _, _}), do: kmin

  @doc "Get the maximum i value."
  @spec imax(S.bbox3i()) :: integer()
  def imax({_, _, _, imax, _, _}), do: imax

  @doc "Get the maximum j value."
  @spec jmax(S.bbox3i()) :: integer()
  def jmax({_, _, _, _, jmax, _}), do: jmax

  @doc "Get the maximum k value."
  @spec kmax(S.bbox3i()) :: integer()
  def kmax({_, _, _, _, _, kmax}), do: kmax

  # --------------
  # public methods
  # --------------

  @doc "Get the integer volume of the bounding box."
  @spec volume(S.bbox3i()) :: integer()
  def volume({imin, jmin, kmin, imax, jmax, kmax}) do
    (imax - imin + 1) * (jmax - jmin + 1) * (kmax - kmin + 1)
  end

  @doc "Get the bounding box as point and width & height & depth."
  @spec to_pos_dims(S.bbox3i()) :: {S.pos3i(), S.dim3()}
  def to_pos_dims({imin, jmin, kmin, imax, jmax, kmax}) do
    {{imin, jmin, kmin}, {imax - imin + 1, jmax - jmin + 1, kmax - kmin + 1}}
  end

  @doc "Get the bounding box as two corner points."
  @spec to_pos2i(S.bbox3i()) :: {S.pos3i(), S.pos3i()}
  def to_pos2i({imin, jmin, kmin, imax, jmax, kmax}) do
    {{imin, jmin, kmin}, {imax, jmax, kmax}}
  end

  @doc "Get the bounding box that covers both the arguments."
  @spec union(S.bbox3i(), S.bbox3i()) :: S.bbox3i()
  def union(
        {imin1, jmin1, kmin1, imax1, jmax1, kmax1},
        {imin2, jmin2, kmin2, imax2, jmax2, kmax2}
      ) do
    {
      min(imin1, imin2),
      min(jmin1, jmin2),
      min(kmin1, kmin2),
      max(imax1, imax2),
      max(jmax1, jmax2),
      max(kmax1, kmax2)
    }
  end

  @doc """
  Get the intersection of two bounding boxes, 
  or error if the intersection has no area.
  """
  @spec intersect(S.bbox3i(), S.bbox3i()) :: bbox3i_type()
  def intersect(
        {imin1, jmin1, kmin1, imax1, jmax1, kmax1},
        {imin2, jmin2, kmin2, imax2, jmax2, kmax2}
      ) do
    new(
      max(imin1, imin2),
      max(jmin1, jmin2),
      max(kmin1, kmin2),
      min(imax1, imax2),
      min(jmax1, jmax2),
      min(kmax1, kmax2)
    )
  end

  @doc "Test the relation of a point to the bounding box."
  @spec classify(S.bbox3i(), S.pos3i()) :: S.in_shape3d()
  def classify({imin, jmin, kmin, imax, jmax, kmax}, {i, j, k}) do
    # test values  :inside  :outside  :on_point
    itest = BBox1i.classify({imin, imax}, i)
    jtest = BBox1i.classify({jmin, jmax}, j)
    ktest = BBox1i.classify({kmin, kmax}, k)

    iin? = itest == :inside
    jin? = jtest == :inside
    kin? = ktest == :inside

    iout? = itest == :outside
    jout? = jtest == :outside
    kout? = ktest == :outside

    cond do
      iin? and jin? and kin? ->
        :inside

      iout? or jout? or kout? ->
        :outside

      true ->
        ieq = if itest == :on_point, do: 1, else: 0
        jeq = if jtest == :on_point, do: 1, else: 0
        keq = if ktest == :on_point, do: 1, else: 0

        case ieq + jeq + keq do
          1 -> :on_face
          2 -> :on_edge
          3 -> :on_point
        end
    end
  end
end
