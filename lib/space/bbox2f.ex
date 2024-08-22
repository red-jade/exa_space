defmodule Exa.Space.BBox2f do
  @moduledoc "A 2D axis-aligned bounding box with float coordinates."

  use Exa.Constants

  import Exa.Types
  alias Exa.Types, as: E

  alias Exa.Math

  alias Exa.Space.Types, as: S

  alias Exa.Space.Pos2f

  @typedoc """
  A valid bounding box, or a reason for error:
  - degenerate: at least one of the min/max pairs is equal within epsilon
  - error: at least one of the min/max pairs has `min>max+epsilon`.
  """
  @type bbox2f_type() :: {:ok, S.bbox2f()} | :degenerate | :error

  # -----------
  # constructor
  # -----------

  @doc "Get the bounding box from float bounding values."
  @spec new(float(), float(), float(), float(), E.epsilon()) :: bbox2f_type()
  def new(xmin, ymin, xmax, ymax, eps \\ @epsilon)
      when is_float(xmin) and is_float(ymin) and is_float(xmax) and is_float(ymax) do
    # TODO - should use Math here?
    cond do
      xmin < xmax - eps and ymin < ymax - eps -> {:ok, {xmin, ymin, xmax, ymax}}
      xmin > xmax + eps -> :error
      ymin > ymax + eps -> :error
      xmin > xmax - eps -> :degenerate
      ymin > ymax - eps -> :degenerate
    end
  end

  @doc "Get the bounding box from integer bounding values."
  @spec from_ints(integer(), integer(), integer(), integer()) :: bbox2f_type()

  def from_ints(imin, _, imax, _) when imin > imax, do: :error
  def from_ints(_, jmin, _, jmax) when jmin > jmax, do: :error
  def from_ints(imin, _, imin, _), do: :degenerate
  def from_ints(_, jmin, _, jmin), do: :degenerate

  def from_ints(imin, jmin, imax, jmax) when is_number(imin) and is_number(jmin),
    do: {:ok, {1.0 * imin, 1.0 * jmin, 1.0 * imax, 1.0 * jmax}}

  @doc "Get the bounding box of lower-left minimum point and width & height."
  @spec from_pos_dims(S.pos2f(), {number(), number()}) :: S.bbox2f()
  def from_pos_dims({xmin, ymin}, {w, h})
      when is_float(xmin) and is_float(ymin) and
             is_number(w) and w > 0 and is_number(h) and h > 0 do
    {xmin, ymin, xmin + w, ymin + h}
  end

  @doc "Get the bounding box of center point and width & height."
  @spec from_center_dims(S.pos2f(), {E.pos_float(), E.pos_float()}) :: S.bbox2f()
  def from_center_dims({cx, cy}, {w, h}) when is_pos_float(w) and is_pos_float(h) do
    w2 = 0.5 * w
    h2 = 0.5 * h
    {cx - w2, cy - h2, cx + w2, cy + h2}
  end

  @doc "Get the bounding box of two points."
  @spec from_corners(S.pos2f(), S.pos2f(), E.epsilon()) :: bbox2f_type()
  def from_corners({x1, y1}, {x2, y2}, eps \\ @epsilon) do
    new(min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2), eps)
  end

  @doc "Get the bounding box of a list of points."
  @spec from_coords(S.coords2f(), E.epsilon()) :: bbox2f_type()
  def from_coords([{x, y} | ps], eps \\ @epsilon) when ps != [] do
    {xmin, ymin, xmax, ymax} =
      Enum.reduce(ps, {x, y, x, y}, fn {x, y}, {xmin, ymin, xmax, ymax} ->
        {min(x, xmin), min(y, ymin), max(x, xmax), max(y, ymax)}
      end)

    new(xmin, ymin, xmax, ymax, eps)
  end

  # ---------
  # accessors
  # ---------

  @spec xmin(S.bbox2f()) :: float()
  def xmin({xmin, _, _, _}), do: xmin

  @spec ymin(S.bbox2f()) :: float()
  def ymin({_, ymin, _, _}), do: ymin

  @spec xmax(S.bbox2f()) :: float()
  def xmax({_, _, xmax, _}), do: xmax

  @spec ymax(S.bbox2f()) :: float()
  def ymax({_, _, _, ymax}), do: ymax

  # --------------
  # public methods
  # --------------

  @spec equals?(S.bbox2f(), S.bbox2f(), E.epsilon()) :: bool()
  def equals?({xmin1, ymin1, xmax1, ymax1}, {xmin2, ymin2, xmax2, ymax2}, eps \\ @epsilon)
      when is_eps(eps) do
    Pos2f.equals?({xmin1, ymin1}, {xmin2, ymin2}, eps) and
      Pos2f.equals?({xmax1, ymax1}, {xmax2, ymax2}, eps)
  end

  @doc "Convert the BBox to the minimum corner position, width and height."
  @spec to_pos_dims(S.bbox2f()) :: {S.pos2f(), {E.pos_float(), E.pos_float()}}
  def to_pos_dims({xmin, ymin, xmax, ymax}), do: {{xmin, ymin}, {xmax - xmin, ymax - ymin}}

  @doc "Convert the BBox to a center position, width and height."
  @spec to_center_dims(S.bbox2f()) :: {S.pos2f(), {E.pos_float(), E.pos_float()}}
  def to_center_dims({xmin, ymin, xmax, ymax}) do
    {{(xmin + xmax) / 2, (ymin + ymax) / 2}, {xmax - xmin, ymax - ymin}}
  end

  @doc "Convert the min and max corners to positions."
  @spec to_pos2f(S.bbox2f()) :: {S.pos2f(), S.pos2f()}
  def to_pos2f({xmin1, ymin1, xmax1, ymax1}) do
    {{xmin1, ymin1}, {xmax1, ymax1}}
  end

  @doc "Convert the four corners to a list of coordinates."
  @spec coords2f(S.bbox2f()) :: S.coords2f()
  def coords2f({x1, y1, x2, y2}), do: [{x1, y1}, {x2, y1}, {x2, y2}, {x1, y2}]

  @doc "Get the area of the BBox."
  @spec area(S.bbox2f()) :: E.pos_float()
  def area({xmin, ymin, xmax, ymax}), do: (xmax - xmin) * (ymax - ymin)

  @doc "Get the bounding box that covers both the arguments."
  @spec union(S.bbox2f(), S.bbox2f()) :: S.bbox2f()
  def union({xmin1, ymin1, xmax1, ymax1}, {xmin2, ymin2, xmax2, ymax2}) do
    {min(xmin1, xmin2), min(ymin1, ymin2), max(xmax1, xmax2), max(ymax1, ymax2)}
  end

  @doc """
  Get the intersection of two bounding boxes.

  The result is either a valid bbox, or a reason for error:
  - degenerate: the bboxes overlap just at a corner or edge, within epsilon
  - error: the bboxes do not overlap, 
    they are more than epsilon away from each other
  """
  @spec intersect(S.bbox2f(), S.bbox2f()) :: bbox2f_type()
  def intersect({xmin1, ymin1, xmax1, ymax1}, {xmin2, ymin2, xmax2, ymax2}, eps \\ @epsilon) do
    new(max(xmin1, xmin2), max(ymin1, ymin2), min(xmax1, xmax2), min(ymax1, ymax2), eps)
  end

  @doc "Test the relation of a point to the bounding box."
  @spec classify(S.bbox2f(), S.pos2f(), E.epsilon()) :: S.in_shape2d()
  def classify({xmin, ymin, xmax, ymax}, {x, y}, eps \\ @epsilon) when is_eps(eps) do
    xbetween = Math.between(xmin, x, xmax, eps)
    ybetween = Math.between(ymin, y, ymax, eps)

    xbet? = xbetween == :between
    ybet? = ybetween == :between

    if xbet? and ybet? do
      :inside
    else
      xeq? = xbetween in [:equal_min, :equal_max]
      yeq? = ybetween in [:equal_min, :equal_max]

      cond do
        xeq? and yeq? -> :on_point
        xbet? and yeq? -> :on_edge
        ybet? and xeq? -> :on_edge
        true -> :outside
      end
    end
  end

  @doc """
  Quick test for a point to be not outside the bounding box.

  If it is not `in?` that does not mean it would classify as `:inside`,
  because there are other classifications on the boundary.
  """
  @spec in?(S.bbox2f(), S.pos2f(), E.epsilon()) :: bool()
  def in?({xmin, ymin, xmax, ymax}, {x, y}, eps \\ @epsilon) when is_eps(eps) do
    Math.compare(x, xmin, eps) != :below and
      Math.compare(x, xmax, eps) != :above and
      Math.compare(y, ymin, eps) != :below and
      Math.compare(y, ymax, eps) != :above
  end
end
