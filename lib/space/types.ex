defmodule Exa.Space.Types do
  @moduledoc "Types and guards for spatial utilities."

  import Exa.Types
  alias Exa.Types, as: E

  @typedoc """
  A dim is just a discrete non-degenerate count of 
  elements in a logical dimension (e.g. width, height, depth).

  Zero-based indices will be in the range `0..dim-1`.
  """
  @type dim() :: E.count1()
  defguard is_dim(d) when is_count1(d)

  @typedoc "Dimensions in 2D, so width and height."
  @type dim2() :: {dim(), dim()}
  defguard is_dim2(d2) when is_tuple(d2) and is_dim(elem(d2, 0)) and is_dim(elem(d2, 1))

  @typedoc "Dimensions in 3D, so width, height and depth."
  @type dim3() :: {dim(), dim(), dim()}
  defguard is_dim3(d3)
           when is_tuple(d3) and
                  is_dim(elem(d3, 0)) and is_dim(elem(d3, 1)) and is_dim(elem(d3, 2))

  @typedoc "Spatial components for points and vectors."
  @type spatial() :: :x | :y | :z | :dx | :dy | :dz | :nx | :ny | :nz

  @typedoc "Classify a 2D point with respect to a 2D vector (ray) direction."
  @type on_axis() :: :left_axis | :on_axis | :right_axis

  @typedoc "Classify a 2D point with respect to a finite 2D line segment."
  @type on_ray() :: {:inside | :outside, on_axis(), E.between()}

  @typedoc """
  Orientation of a surface with respect to a vector or axis,
  typically the +ve z-axis, which is -ve view vector in NDC.

  - `:ccw` Counter Clockwise: right-handed +ve orientation; 
    right-hansded normal is parallel to z-axis, 
    anti-parallel to view vector, or _front_ facing.
    This is the usual rotation for 2D x-y plane in mathematics:
    angles are measured anti-clockwise from the x-axis.

  - `:cw` Clockwise: left-handed -ve orientation: 
    right-handed normal is anti-parallel to z-axis, 
    parallel to the view vector, or _back_ facing.

  - `:degenerate` means the input points are collinear, 
    vectors are parallel, and area is zero (to some tolerance).

  """
  @type orientation() :: :ccw | :cw | :degenerate

  @typedoc """
  Classify a 1D point with respect to a 1D line or 1D bounding box.
  This is the same as `Exa.Math` betweenness.

  The values come from approximate floating-point arithmetic:

  - `:inside`: on the inside of the bbox, 
     at least epsilon away from the boundary 
  - `:outside`: on the outside of the bbox,
     more than epsilon away from the boundary
  - `:on_point`: within epsilon of an endpoint
    (equal min or equal max)
  """
  @type in_shape1d() :: :inside | :outside | :on_point

  @typedoc """
  Classify a 2D point with respect to a 2D shape or 2D bounding box.

  The values give location relative to the boundary:
  - `:inside`: on the inside of the bbox, 
     at least epsilon away from the boundary 
  - `:outside`: on the outside of the bbox,
     more than epsilon away from the boundary
  - `:on_point`: within epsilon of a corner point
  - `:on_edge`: within epsilon of a boundary edge
  """
  @type in_shape2d() :: in_shape1d() | :on_edge

  @typedoc """
  Classify a 3D point with respect to a 3D shape or 3D bounding box.

  The values give location relative to the boundary:
  - `:inside`: on the inside of the bbox, 
     at least epsilon away from the boundary 
  - `:outside`: on the outside of the bbox,
     more than epsilon away from the boundary
  - `:on_point`: within epsilon of a corner point
  - `:on_edge`: within epsilon of a boundary edge
  - `:on_face`: within epsilon of a boundary face
  """
  @type in_shape3d() :: in_shape2d() | :on_face

  # ---------
  # positions
  # ---------

  @type pos2i() :: {integer(), integer()}
  defguard is_pos2i(p)
           when is_fix_tuple(p, 2) and
                  is_integer(elem(p, 0)) and is_integer(elem(p, 1))

  @type coords2i() :: [pos2i(), ...]
  defguard is_coords2i(cs) when is_list(cs) and cs != [] and is_pos2i(hd(cs))

  @type pos3i() :: {integer(), integer(), integer()}
  defguard is_pos3i(p)
           when is_fix_tuple(p, 3) and
                  is_integer(elem(p, 0)) and is_integer(elem(p, 1)) and is_integer(elem(p, 2))

  @type coords3i() :: [pos3i(), ...]
  defguard is_coords3i(cs) when is_list(cs) and cs != [] and is_pos3i(hd(cs))

  @type pos2f() :: {float(), float()}
  defguard is_pos2f(p)
           when is_fix_tuple(p, 2) and
                  is_float(elem(p, 0)) and is_float(elem(p, 1))

  @type coords2f() :: [pos2f(), ...]
  defguard is_coords2f(cs) when is_list(cs) and cs != [] and is_pos2f(hd(cs))

  @type pos3f() :: {float(), float(), float()}
  defguard is_pos3f(v)
           when is_fix_tuple(v, 3) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1)) and is_float(elem(v, 2))

  @type pos4f() :: {float(), float(), float(), float()}
  defguard is_pos4f(v)
           when is_fix_tuple(v, 4) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1)) and
                  is_float(elem(v, 2)) and is_float(elem(v, 3))

  @type coords3f() :: [pos3f(), ...]
  defguard is_coords3f(cs) when is_list(cs) and cs != [] and is_pos3f(hd(cs))

  # -------
  # vectors
  # -------

  @type vec2i() :: {integer(), integer()}
  defguard is_vec2i(v)
           when is_fix_tuple(v, 2) and
                  is_integer(elem(v, 0)) and is_integer(elem(v, 1))

  @type vec2f() :: {float(), float()}
  defguard is_vec2f(v)
           when is_fix_tuple(v, 2) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1))

  @type vec3f() :: {float(), float(), float()}
  defguard is_vec3f(v)
           when is_fix_tuple(v, 3) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1)) and is_float(elem(v, 2))

  @type vec4f() :: {float(), float(), float(), float()}
  defguard is_vec4f(v)
           when is_fix_tuple(v, 4) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1)) and
                  is_float(elem(v, 2)) and is_float(elem(v, 3))

  # ------------
  # bounding box
  # ------------

  @type bbox1i() :: {integer(), integer()}
  defguard is_bbox1i(v)
           when is_fix_tuple(v, 2) and
                  is_integer(elem(v, 0)) and is_integer(elem(v, 1)) and
                  elem(v, 0) <= elem(v, 1)

  @type bbox2i() :: {integer(), integer(), integer(), integer()}
  defguard is_bbox2i(v)
           when is_fix_tuple(v, 4) and
                  is_integer(elem(v, 0)) and is_integer(elem(v, 1)) and
                  is_integer(elem(v, 2)) and is_integer(elem(v, 3)) and
                  elem(v, 0) <= elem(v, 2) and
                  elem(v, 1) <= elem(v, 3)

  @type bbox3i() :: {integer(), integer(), integer(), integer(), integer(), integer()}
  defguard is_bbox3i(v)
           when is_fix_tuple(v, 6) and
                  is_integer(elem(v, 0)) and is_integer(elem(v, 1)) and
                  is_integer(elem(v, 2)) and is_integer(elem(v, 3)) and
                  is_integer(elem(v, 4)) and is_integer(elem(v, 5)) and
                  elem(v, 0) <= elem(v, 3) and
                  elem(v, 1) <= elem(v, 4) and
                  elem(v, 2) <= elem(v, 5)

  @type bbox2f() :: {float(), float(), float(), float()}
  defguard is_bbox2f(v)
           when is_fix_tuple(v, 4) and
                  is_float(elem(v, 0)) and is_float(elem(v, 1)) and
                  is_float(elem(v, 2)) and is_float(elem(v, 3)) and
                  elem(v, 0) < elem(v, 2) and elem(v, 1) < elem(v, 3)

  # -----------------
  # matrix transforms
  # -----------------

  @typedoc "A 2D array of values in row-major order."
  @type mat22() :: :iden22 | {float(), float(), float(), float()}

  defguard is_mat22(m) when m == :iden22 or is_fix_tuple(m, 4)

  @typedoc "A 3D array of values in row-major order."
  @type mat33() ::
          :iden33
          | {
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float()
            }

  defguard is_mat33(m) when m == :iden33 or is_fix_tuple(m, 9)

  @typedoc "A 4D array of values in row-major order."
  @type mat44() ::
          :iden44
          | {
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float(),
              float()
            }

  defguard is_mat44(m) when m == :iden44 or is_fix_tuple(m, 16)

  @typedoc "A general type for all square matrices."
  @type matrix() :: mat22() | mat33() | mat44()
  defguard is_matrix(m) when is_tuple(m) and tuple_size(m) in [4, 9, 16]

  # ---------------
  # part transforms
  # ---------------

  @type xlate2d() :: vec2f()
  @type scale2d() :: float() | {float(), float()}
  @type skew2d() :: float() | {float(), float()}
  @type rotate2d() :: E.degrees()

  @type transform2d() :: {:matrix2, mat33()} | {:trans2, xlate2d(), rotate2d(), scale2d()}

  @type xlate3d() :: vec3f()
  @type scale3d() :: float() | {float(), float(), float()}
  @type skew3d() :: float() | {float(), float(), float()}
  @type rotate3d() :: {E.degrees(), vec3f()}

  @type transform3d() :: {:matrix3, mat44()} | {:trans3, xlate2d(), rotate2d(), scale2d()}

  # ----------------
  # transform stacks
  # ----------------

  @typedoc "
  A stack of 2D homogeneous transforms (3x3 matrices).

  The stack is pushed/popped when traversing/returning from children.

  Matrices are post-multiplied onto the current head of the stack.
  "
  @type xform2d_stack() :: [mat33()]
end
