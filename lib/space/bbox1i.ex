defmodule Exa.Space.BBox1i do
  @moduledoc """
  A 1D interval bound (range) box with non-negative integer coordinates.

  Equivalent to a single positive `Range`.
  """

  use Exa.Constants

  import Exa.Types

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  @typedoc """
  A valid bounding box, or a reason for error:
  the maximum is less than the minimum.
  """
  @type bbox1i_type() :: {:ok, S.bbox1i()} | :error

  # -----------
  # constructor
  # -----------

  @doc "Get the bounding box from bounding values."
  @spec new(integer(), integer()) :: bbox1i_type()
  def new(imin, imax) when is_integer(imin) and is_integer(imax) do
    cond do
      imin <= imax -> {:ok, {imin, imax}}
      imin > imax -> :error
    end
  end

  @doc "Get the bounding box of a minimum value and a length."
  @spec from_pos_w(integer(), S.dim()) :: S.bbox1i()
  def from_pos_w(i, w) when is_integer(i) and is_dim(w) do
    {i, i + w - 1}
  end

  @doc "Get the bounding box of two values. Allow incorrect ordering, no errors."
  @spec from_points(integer(), integer()) :: S.bbox1i()
  def from_points(i1, i2), do: {min(i1, i2), max(i1, i2)}

  @doc "Get the bounding box of a list of points."
  @spec from_coords([integer()]) :: S.bbox1i()
  def from_coords([i0 | is]) when is_list(is) and is != [] do
    Enum.reduce(is, {i0, i0}, fn i, {imin, imax} when is_integer(i) ->
      {min(i, imin), max(i, imax)}
    end)
  end

  @doc "Get the bounding box from a range."
  @spec from_range(Range.t()) :: S.bbox1i()
  def from_range(%Range{first: imin, last: imax, step: 1}), do: {imin, imax}

  # ---------
  # accessors
  # ---------

  @spec imin(S.bbox1i()) :: integer()
  def imin({imin, _}), do: imin

  @spec imax(S.bbox1i()) :: integer()
  def imax({_, imax}), do: imax

  # --------------
  # public methods
  # --------------

  # equals? use ==

  @spec width(S.bbox1i()) :: integer()
  def width({imin, imax}), do: imax - imin + 1

  @doc "Get the bounding box as point and width."
  @spec to_pos_w(S.bbox1i()) :: {integer(), S.dim()}
  def to_pos_w({imin, imax}), do: {imin, imax - imin + 1}

  @doc "Get the bounding box as a range."
  @spec to_range(S.bbox1i()) :: Range.t()
  def to_range({imin, imax}) when is_range(imin, imax), do: imin..imax

  @doc "Get the bounding box that covers both the arguments."
  @spec union(S.bbox1i(), S.bbox1i()) :: S.bbox1i()
  def union({imin1, imin2}, {imax1, imax2}), do: {min(imin1, imin2), max(imax1, imax2)}

  @doc """
  Get the intersection of two bounding boxes, 
  or error if the intersection has no area.
  """
  @spec intersect(S.bbox1i(), S.bbox1i()) :: bbox1i_type()
  def intersect({imin1, imax1}, {imin2, imax2}) do
    new(max(imin1, imin2), min(imax1, imax2))
  end

  @doc "Test the relation of a point to the bounding box."
  @spec classify(S.bbox1i(), integer()) :: S.in_shape1d()
  def classify({i, _imax}, i), do: :on_point
  def classify({_imin, i}, i), do: :on_point
  def classify({imin, imax}, i) when i > imin and i < imax, do: :inside
  def classify(_, _), do: :outside
end
