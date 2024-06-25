defmodule Exa.Space.Xform do
  @moduledoc """
  Spatial transformations implemented with matrices.

  ### Matrices

  A matrix is an NxN array of floating-point values.

  The base format of a matrix is a single tuple
  with values in row-major order.

  Transposed column-major array format is also available,
  but the physical formats are indistinguishable.
  The semantics must be maintained by the usage.

  Matrix dimensions are expressed as _MxN_ meaning
   _(no. of rows) x (no. of columns)._

  Matrix elements are labelled and addressed by 
  index coordinates _(i,j),_ 
  where _i_ is 1-based row number,
  and _j_ is 1-based column number.
  For example, a 2x2 matrix:

  ```
  ( m11, m12 )
  ( m21, m22 )
  ```

  The matrix values are layed out in row-major order,
  which means each row is contiguous: 
  the i-index varies slowly,
  and the j-index varies quickly.
  For example, a 2x2 matrix is the tuple:

  ` m11, m12, m21, m22 }`

  ### Transformations

  There are two vector spaces to which the transforms apply:
  - 2D dimensions
  - 3D dimensions

  There are three classes of transformation for each vector space:
  - linear: scaling and rotation about the origin
  - affine: linear plus translations
  - projective: affine plus division 

  There are different ways to implement transforms for a space.

  In 2D space:
  - linear: 2x2 matrix multiplication
  - affine: 
    - linear 2x2 matrix multiplication 
      with a 1x2 vector addition for the translation
    - lift the 2D vectors and 2x2 matrix into 3D homogeneous coordinates,
      with fixed extra components, then apply a 3x3 projective matrix multiplcation...
  - projective: generalized 3x3 multiplication, 
    with division by the 3<sup>rd</sup> coordinate to produce the final 2D vector

  In 3D space:
  - linear: 3x3 matrix multiplication
  - affine: 
    - linear 3x3 matrix multiplication 
      with a 1x3 vector addition for the translation
    - lift the 3D vectors and 3x3 matrix into 4D homogeneous coordinates,
      with fixed extra components, then apply a 4x4 projective matrix multiplcation...
  - projective: generalized 4x4 multiplication, 
    with division by the 4<sup>th</sup> coordinate to produce the final 2D vector

  To lift from regular Cartesian coordinates to homogeneous coordinates:
  - append a `1.0` coordinate to all vectors
  - append an identity row `0.0, 0.0, ... 1.0` to each matrix

  To project from homogeneous coordinates back to Cartesian coordinates:
  - divide the first N-1 vector components by the N<sup>th</sup> coordinate value,
    but if that divisor is at, or close to, zero, 
    then the projection is out-of-bounds towards infinity (degenerate).


  ### Implementation

  The current implementation only supports square matrices.

  The dimensions are limited to 2x2, 3x3 and 4x4.
  """

  # ===============================
  # DO NOT MIX-FORMAT THIS FILE !!!
  # DO NOT LET YOUR EDITOR REFORMAT
  # note excluded in .formatter.exs
  # ===============================

  use Exa.Constants

  alias Exa.Types, as: E

  import Exa.Space.Types
  alias Exa.Space.Types, as: S

  alias Exa.Math
  alias Exa.Space.Vec2f
  alias Exa.Space.Vec3f
  alias Exa.Space.Vec4f

  # -----------
  # local types
  # -----------

  @doc "A 1-based positive integer index to reference matrix element."
  @type index() :: pos_integer()
  defguard is_index(i,n) when is_integer(i) and n in [2,3,4] and i >= 1 and i <= n

  # ---------
  # constants
  # ---------

  @iden22 {
    1.0, 0.0,
    0.0, 1.0
  }

  @iden33 {
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0
  }

  @iden44 {
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0
  }

  # ------------
  # constructors
  # ------------

  @doc "Create a 2x2 identity matrix."
  @spec iden22() :: S.mat22()
  def iden22(), do: :iden22

  @doc "Create a 3x3 identity matrix."
  @spec iden33() :: S.mat33()
  def iden33(), do: :iden33

  @doc "Create a 4x4 identity matrix."
  @spec iden44() :: S.mat44()
  def iden44(), do: :iden44

  @doc "Create a new 2x2 matrix. Values can be float or integer."
  @spec new22(
    number(), number(), 
    number(), number()
  ) :: S.mat22()

  def new22(m11, m12, m21, m22)
      when is_float(m11) and is_float(m12) and
           is_float(m21) and is_float(m22) do
    {m11, m12,
     m21, m22}
  end

  def new22(m11, m12, m21, m22)
      when is_number(m11) and is_number(m12) and
           is_number(m21) and is_number(m22) do
    {
      1.0*m11, 1.0*m12, 
      1.0*m21, 1.0*m22
    }
  end

  @doc "Create a new 3x3 matrix. Values can be float or integer."
  @spec new33(
    number(), number(), number(), 
    number(), number(), number(), 
    number(), number(), number()
  ) :: S.mat33()

  def new33(
        m11, m12, m13,
        m21, m22, m23,       
        m31, m32, m33
      )
      when is_float(m11) and is_float(m12) and is_float(m13) and
           is_float(m21) and is_float(m22) and is_float(m23) and
           is_float(m31) and is_float(m32) and is_float(m33) do
    {
      m11, m12, m13,
      m21, m22, m23,
      m31, m32, m33
    }
  end

  def new33(
        m11, m12, m13,
        m21, m22, m23,       
        m31, m32, m33
      )
      when is_number(m11) and is_number(m12) and is_number(m13) and
           is_number(m21) and is_number(m22) and is_number(m23) and
           is_number(m31) and is_number(m32) and is_number(m33) do
    {
      1.0*m11, 1.0*m12, 1.0*m13,
      1.0*m21, 1.0*m22, 1.0*m23,       
      1.0*m31, 1.0*m32, 1.0*m33
    }
  end

  @doc "Create a new 4x4 matrix. Values can be float or integer."
  @spec new44(
    number(), number(), number(), number(),
    number(), number(), number(), number(),
    number(), number(), number(), number(),
    number(), number(), number(), number()
  ) :: S.mat44()

  def new44(
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
      )
      when is_float(m11) and is_float(m12) and is_float(m13) and is_float(m14) and
           is_float(m21) and is_float(m22) and is_float(m23) and is_float(m24) and
           is_float(m31) and is_float(m32) and is_float(m33) and is_float(m34) and
           is_float(m41) and is_float(m42) and is_float(m43) and is_float(m44) do
    {
      m11, m12, m13, m14,
      m21, m22, m23, m24,
      m31, m32, m33, m34,
      m41, m42, m43, m44
    }
  end

  def new44(
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
      )
      when is_number(m11) and is_number(m12) and is_number(m13) and is_number(m14) and
           is_number(m21) and is_number(m22) and is_number(m23) and is_number(m24) and
           is_number(m31) and is_number(m32) and is_number(m33) and is_number(m34) and
           is_number(m41) and is_number(m42) and is_number(m43) and is_number(m44) do
    {
      1.0*m11, 1.0*m12, 1.0*m13, 1.0*m14,
      1.0*m21, 1.0*m22, 1.0*m23, 1.0*m24,
      1.0*m31, 1.0*m32, 1.0*m33, 1.0*m34,
      1.0*m41, 1.0*m42, 1.0*m43, 1.0*m44
    }
  end

  # -------------------
  # access and equality
  # -------------------

  @doc "Get the _(i,j)_ element of the matrix."
  @spec element(S.matrix(), index(), index()) :: float()
  def element(:iden22, i, i) when is_index(i,2), do: 1.0
  def element(:iden22, i, j) when is_index(i,2) and is_index(j,3), do: 0.0
  def element(:iden33, i, i) when is_index(i,3), do: 1.0
  def element(:iden33, i, j) when is_index(i,3) and is_index(j,3), do: 0.0
  def element(:iden44, i, i) when is_index(i,4), do: 1.0
  def element(:iden44, i, j) when is_index(i,4) and is_index(j,4), do: 0.0
  def element(m, i, j) when is_mat22(m) and is_index(i,2), do: elem(m, 2*(i-1)+j-1)
  def element(m, i, j) when is_mat33(m) and is_index(i,3), do: elem(m, 3*(i-1)+j-1)
  def element(m, i, j) when is_mat44(m) and is_index(i,4), do: elem(m, 4*(i-1)+j-1)

  @doc "Get the trace of the matrix."
  @spec trace(S.matrix()) :: float()
  def trace(:iden22), do: 2.0
  def trace(:iden33), do: 3.0
  def trace(:iden44), do: 4.0
  def trace(m) when is_mat22(m), do: elem(m,0) + elem(m,3)
  def trace(m) when is_mat33(m), do: elem(m,0) + elem(m,4) + elem(m,8) 
  def trace(m) when is_mat44(m), do: elem(m,0) + elem(m,5) + elem(m,10) + elem(m,15)

  @spec equals?(S.matrix(), S.matrix(), E.epsilon()) :: bool()
  def equals?(a, b, eps \\ @epsilon)
  def equals?(:iden22, :iden22, _), do: true
  def equals?(:iden33, :iden33, _), do: true
  def equals?(:iden44, :iden44, _), do: true
  def equals?(:iden22, b, eps), do: equals?(@iden22, b, eps)
  def equals?(a, :iden22, eps), do: equals?(a, @iden22, eps)
  def equals?(:iden33, b, eps), do: equals?(@iden33, b, eps)
  def equals?(a, :iden33, eps), do: equals?(a, @iden33, eps)
  def equals?(:iden44, b, eps), do: equals?(@iden44, b, eps)
  def equals?(a, :iden44, eps), do: equals?(a, @iden44, eps)
  def equals?(a, b, eps) do
    Exa.Tuple.bireduce(a, b, true, fn aij, bij, eq? -> eq? and Math.equals?(aij,bij,eps) end)
  end

  # -------------------------
  # pointwise mul/add/sub/dot
  # -------------------------

  # TODO - optimize the identity forms, if necessary

  @doc "Pointwise multiplication by a constant scalar factor."
  @spec mul(number(), S.matrix()) :: S.matrix()
  def mul(x, :iden22) when is_number(x), do: mul(x, @iden22)
  def mul(x, :iden33) when is_number(x), do: mul(x, @iden33)
  def mul(x, :iden44) when is_number(x), do: mul(x, @iden44)
  def mul(x, m) when is_number(x) and is_matrix(m), do: Exa.Tuple.map(m, & x * &1)

  @doc "Pointwise addition of two matrices with the same size."
  @spec add(S.matrix(), S.matrix()) :: S.matrix()
  def add(a, :iden22) when is_mat22(a), do: add(a, @iden22)
  def add(:iden22, b) when is_mat22(b), do: add(@iden22, b)
  def add(a, :iden33) when is_mat33(a), do: add(a, @iden33)
  def add(:iden33, b) when is_mat33(b), do: add(@iden33, b)
  def add(a, :iden44) when is_mat44(a), do: add(a, @iden44)
  def add(:iden44, b) when is_mat44(b), do: add(@iden44, b)
  def add(a, b) when is_matrix(a) and is_matrix(b) and tuple_size(a) == tuple_size(b) do 
    Exa.Tuple.zip_with(a, b, &Kernel.+/2)
  end

  @doc "Pointwise subtraction of two matrices with the same size."
  @spec sub(S.matrix(), S.matrix()) :: S.matrix()
  def sub(a, :iden22) when is_mat22(a), do: sub(a, @iden22)
  def sub(:iden22, b) when is_mat22(b), do: sub(@iden22, b)
  def sub(a, :iden33) when is_mat33(a), do: sub(a, @iden33)
  def sub(:iden33, b) when is_mat33(b), do: sub(@iden33, b)
  def sub(a, :iden44) when is_mat44(a), do: sub(a, @iden44)
  def sub(:iden44, b) when is_mat44(b), do: sub(@iden44, b)
  def sub(a, b) when is_matrix(a) and is_matrix(b) and tuple_size(a) == tuple_size(b) do 
    Exa.Tuple.zip_with(a, b, &Kernel.-/2)
  end

  @doc "Pointwise multiplication of two matrices with the same size, like a dot product."
  @spec dot(S.matrix(), S.matrix()) :: S.matrix()
  def dot(a, :iden22) when is_mat22(a), do: dot(a, @iden22)
  def dot(:iden22, b) when is_mat22(b), do: dot(@iden22, b)
  def dot(a, :iden33) when is_mat33(a), do: dot(a, @iden33)
  def dot(:iden33,b) when is_mat33(b),  do: dot(@iden33, b)
  def dot(a,:iden44) when is_mat44(a),  do: dot(a, @iden44)
  def dot(:iden44,b) when is_mat44(b),  do: dot(@iden44, b)
  def dot(a, b) when is_matrix(a) and is_matrix(b) and tuple_size(a) == tuple_size(b) do 
    Exa.Tuple.zip_with(a, b, &Kernel.*/2)
  end

  # -----------------
  # common transforms
  # -----------------

  # transforms refer to the usual math (and OpenGL) 2D coordinate system:
  # +ve x to the right; +ve y upwards; a right-handed system;
  # notional z-axis coming out of the plane;
  # rotations anti-clockwise about z-axis from x towards y.

  @doc "Build a 2x2 matrix for scale of x and y."
  @spec scale2d(float(), float()) :: S.mat22()
  def scale2d(sx, sy) when is_float(sx) and is_float(sy), do: {sx, 0.0, 0.0, sy}

  @doc "Build a 2x2 matrix for rotation counter-clockwise (RH) by angle theta degrees."
  @spec rotate2d(E.degrees()) :: S.mat22()
  def rotate2d(theta) when is_float(theta) do
    c = Math.cosd(theta)
    s = Math.sind(theta)
    {c, -s, s, c}
  end

  @doc "Build a 2x2 matrix for counter-clockwise (RH) by 90°."
  @spec rotate2d_90() :: S.mat22()
  def rotate2d_90(), do: {0.0, -1.0, 1.0, 0.0}

  @doc "Build a 2x2 matrix for rotation by 180°."
  @spec rotate2d_180() :: S.mat22()
  def rotate2d_180(), do: {-1.0, 0.0, 0.0, -1.0}

  @doc "Build a 2x2 matrix for rotation counter-clockwise (RH) by 270°."
  @spec rotate2d_270() :: S.mat22()
  def rotate2d_270(), do: {0.0, 1.0, -1.0, 0.0}


  @doc "Build a 2x2 matrix for reflection in a line at angle theta degrees."
  @spec reflect2d(E.degrees()) :: S.mat22()
  def reflect2d(theta) when is_float(theta) do
    theta2 = 2.0 * theta
    c2 = Math.cosd(theta2)
    s2 = Math.sind(theta2)
    {c2, s2, s2, -c2}
  end

  @doc "Build a 2x2 matrix for reflection in x-axis (negate y)."
  @spec reflect2d_x() :: S.mat22()
  def reflect2d_x(), do: {1.0, 0.0, 0.0, -1.0}

  @doc "Build a 2x2 matrix for reflection in y-axis (negate x)."
  @spec reflect2d_y() :: S.mat22()
  def reflect2d_y(), do: {-1.0, 0.0, 0.0, 1.0}

  # TODO - 3D rotations, axis angle, quaternions?

  # ----------------------
  # projective conversions
  # ----------------------

  @doc "Lift a Cartesian vector to homogeneous projective coordinates."
  @spec lift(S.vec2f() | S.vec3f()) :: S.vec3f() | S.vec4f()
  def lift({dx, dy}), do: {dx, dy, 1.0}
  def lift({dx, dy, dz}), do: {dx, dy, dz, 1.0}

  @doc """
  Lift a Cartesian matrix and translation vector
  to homogeneous projective matrix.

  Append the translation as a lifted column vector containing an extra `1.0`,
  and fill the rest of the last row of the matrix with `0.0`.
  """
  @spec lift(S.mat22() | S.mat33(), S.vec2f() | S.vec3f()) :: S.mat33() | S.mat44()

  def lift(:iden22,xlate2) when is_vec2f(xlate2), do: lift(@iden22, xlate2)

  def lift({
        m11, m12,
        m21, m22
      },
      {tx, ty}) do
    {
      m11, m12, tx,
      m21, m22, ty,
      0.0, 0.0, 1.0
    }
  end

  def lift(:iden33,xlate3) when is_vec3f(xlate3), do: lift(@iden33, xlate3)

  def lift({
        m11, m12, m13,
        m21, m22, m23,
        m31, m32, m33
      },
      {tx, ty, tz}) do
    {
      m11, m12, m13, tx,
      m21, m22, m23, ty,
      m31, m32, m33, tz,
      0.0, 0.0, 0.0, 1.0
    }
  end

  @doc """
  Project a homogeneous projective vector to Cartesian coordinates.

  Divide by the last _w_ projective coordinate.
  If _w_ is close to zero, up to some tolerance,
  then report a result of `:degenerate`.
  """
  @spec project(S.vec3f() | S.vec4f(), E.epsilon()) :: :degenerate | S.vec2f() | S.vec3f()
  def project(vec, eps \\ @epsilon)

  def project({dx, dy, dw}, eps) do
    if Math.zero?(dw, eps) do
      :degenerate
    else
      {dx / dw, dy / dw}
    end
  end

  def project({dx, dy, dz, dw}, eps) do
    if Math.zero?(dw, eps) do
      :degenerate
    else
      {dx / dw, dy / dw, dz / dw}
    end
  end

  # -------
  # inverse
  # -------

  @doc """
  The inverse of a matrix.
  The inverse is the matrix that 
  multiplies the original 
  to give the identity matrix.

  If the determinant is approximately zero, subject to a tolerance,
  then the matrix is not invertible, and the result will be `:degenerate`.

  The inverse is calculated as `(1/det(m)) * adj(m)`.

  An identity matrix does not change under inversion.
  """
  @spec inv(S.matrix(), E.epsilon()) :: :degenerate | S.matrix()
  def inv(matrix, eps \\ @epsilon)
  def inv(:iden22, _), do: :iden22
  def inv(:iden33, _), do: :iden33
  def inv(:iden44, _), do: :iden44
  def inv(m, eps) when is_matrix(m) do 
    det = det(m)
    if Math.zero?(det, eps) do
      :degenerate
    else
      mul(1.0/det, adj(m))
    end
  end

  # --------------------
  # adjoint and cofactor
  # --------------------

  @doc """
  Get the adjoint of a matrix.

  The adjoint is the transpose of the cofactor matrix.

  The adjoint of an identity is the identity.
  """
  @spec adj(S.matrix()) :: S.matrix()
  def adj(:iden22, _), do: :iden22
  def adj(:iden33, _), do: :iden33
  def adj(:iden44, _), do: :iden44
  def adj(m), do: m |> cofactor() |> transpose()

  @doc """
  Get the cofactor of a matrix.

  The (i,j) element of the cofactor is defined as:

  `(-1)^(i+j) x det(Cij)`

  where _Cij_ is the original matrix with row i and column j removed.
  """
  @spec cofactor(S.matrix()) :: S.matrix()
  def cofactor(:iden22, _), do: :iden22
  def cofactor(:iden33, _), do: :iden33
  def cofactor(:iden44, _), do: :iden44
  def cofactor({
        m11, m12,
        m21, m22
      }) do
    {
      m22, -m21,
     -m12,  m11
    }
  end

  def cofactor({
        m11, m12, m13,
        m21, m22, m23,
        m31, m32, m33
      }) do
    {
      det({m22,m23, m32,m33}), - det({m21,m23, m31,m33}),   det({m21,m22, m31,m32}),
    - det({m12,m13, m32,m33}),   det({m11,m13, m31,m33}), - det({m11,m12, m31,m32}),
      det({m12,m13, m22,m23}), - det({m11,m13, m21,m23}),   det({m11,m12, m21,m22}),
    }
  end

  def cofactor({
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
      }) do
    {
      det({m22,m23,m24, m32,m33,m34, m42,m43,m44}), 
    - det({m21,m23,m24, m31,m33,m34, m41,m43,m44}),
      det({m21,m22,m24, m31,m32,m34, m41,m42,m44}),
    - det({m21,m22,m23, m31,m32,m33, m41,m42,m43}),

    - det({m12,m13,m14, m32,m33,m34, m42,m43,m44}), 
      det({m11,m13,m14, m31,m33,m34, m41,m43,m44}),
    - det({m11,m12,m14, m31,m32,m34, m41,m42,m44}),
      det({m11,m12,m13, m31,m32,m33, m41,m42,m43}),

      det({m12,m13,m14, m22,m23,m24, m42,m43,m44}), 
    - det({m11,m13,m14, m21,m23,m24, m41,m43,m44}),
      det({m11,m12,m14, m21,m22,m24, m41,m42,m44}),
    - det({m11,m12,m13, m21,m22,m23, m41,m42,m43}),

    - det({m12,m13,m14, m22,m23,m24, m32,m33,m34}), 
      det({m11,m13,m14, m21,m23,m24, m31,m33,m34}),
    - det({m11,m12,m14, m21,m22,m24, m31,m32,m44}),
      det({m11,m12,m13, m21,m22,m23, m31,m32,m33})
    }
  end

  # -----------
  # determinant
  # -----------

  @doc """
  The determinant of a matrix.

  If the determinant is close to zero,
  then the matrix is not invertible.

  The determinant of an identity matrix is `1.0`.
  """
  @spec det(S.matrix()) :: float()

  def det(:iden22), do: 1.0

  def det({
        m11, m12,
        m21, m22
      }) do
    m11 * m22 - 
    m12 * m21
  end

  def det(:iden33), do: 1.0

  def det({
        m11, m12, m13,
        m21, m22, m23,
        m31, m32, m33
      }) do
    m11 * det({m22,m23, m32,m33}) - 
    m12 * det({m21,m23, m31,m33}) +
    m13 * det({m21,m22, m31,m32})
  end

  def det(:iden44), do: 1.0

  def det({
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
      }) do
    m11 * det({m22,m23,m24, m32,m33,m34, m42,m43,m44}) -
    m12 * det({m21,m23,m24, m31,m33,m34, m41,m43,m44}) +
    m13 * det({m21,m22,m24, m31,m32,m34, m41,m42,m44}) -
    m14 * det({m21,m22,m23, m31,m32,m33, m41,m42,m43})
  end

  # ---------
  # transpose
  # ---------

  @doc """
  Transpose a matrix from row-major to column-major format, or vice-versa.

  The transpose is like a reflection in the leading diagonal,
  i.e. the leading diagonal terms stay the same,
  and the off-diagonal terms are exchanged.

  An identity matrix does not change under transposition.
  """
  @spec transpose(S.matrix()) :: S.matrix()

  def transpose(:iden22), do: :iden22

  def transpose({
        m11, m12,
        m21, m22
      }) do
    {
      m11, m21,
      m12, m22
    }
  end

  def transpose(:iden33), do: :iden33

  def transpose({
        m11, m12, m13,
        m21, m22, m23,
        m31, m32, m33
      }) do
    {
      m11, m21, m31,
      m12, m22, m32,
      m13, m23, m33
    }
  end

  def transpose(:iden44), do: :iden44

  def transpose({
        m11, m12, m13, m14,
        m21, m22, m23, m24,
        m31, m32, m33, m34,
        m41, m42, m43, m44
      }) do
    {
      m11, m21, m31, m41,
      m12, m22, m32, m42,
      m13, m23, m33, m43,
      m14, m24, m34, m44
    }
  end

  # ---------------------
  # matrix multiplication
  # ---------------------

  @doc """
  Multiply two matrices.

  Multiplication is implemented by successive dot products
  of row-vectors in the first argument
  with column vectors in the second argument.
  """
  @spec multiply(S.matrix(), S.matrix()) :: S.matrix()

  def multiply(:iden22, m) when is_mat22(m), do: m
  def multiply(m, :iden22) when is_mat22(m), do: m

  def multiply({
        a11, a12,
        a21, a22
      }, 
      {
        b11, b12,
        b21, b22
      }) do
    # rows
    a1 = {a11, a12}
    a2 = {a21, a22}
    # columns
    b1 = {b11, b21}
    b2 = {b12, b22}
    {
      Vec2f.dot(a1, b1), Vec2f.dot(a1, b2),
      Vec2f.dot(a2, b1), Vec2f.dot(a2, b2)
    }
  end

  def multiply(:iden33, m) when is_mat33(m), do: m
  def multiply(m, :iden33) when is_mat33(m), do: m

  def multiply({
        a11, a12, a13,
        a21, a22, a23,
        a31, a32, a33
      },
      {
        b11, b12, b13,
        b21, b22, b23,
        b31, b32, b33
      }) do
    # rows
    a1 = {a11, a12, a13}
    a2 = {a21, a22, a23}
    a3 = {a31, a32, a33}
    # columns
    b1 = {b11, b21, b31}
    b2 = {b12, b22, b32}
    b3 = {b13, b23, b33}
    {
      Vec3f.dot(a1, b1), Vec3f.dot(a1, b2), Vec3f.dot(a1, b3),
      Vec3f.dot(a2, b1), Vec3f.dot(a2, b2), Vec3f.dot(a2, b3),
      Vec3f.dot(a3, b1), Vec3f.dot(a3, b2), Vec3f.dot(a3, b3)
    }
  end

  def multiply(:iden44, m) when is_mat44(m), do: m
  def multiply(m, :iden44) when is_mat44(m), do: m

  def multiply({
        a11, a12, a13, a14,
        a21, a22, a23, a24,
        a31, a32, a33, a34,
        a41, a42, a43, a44
      },
      {
        b11, b12, b13, b14,
        b21, b22, b23, b24,
        b31, b32, b33, b34,
        b41, b42, b43, b44
      }) do
    # rows
    a1 = {a11, a12, a13, a14}
    a2 = {a21, a22, a23, a24}
    a3 = {a31, a32, a33, a34}
    a4 = {a41, a42, a43, a44}
    # columns
    b1 = {b11, b21, b31, b41}
    b2 = {b12, b22, b32, b42}
    b3 = {b13, b23, b33, b43}
    b4 = {b14, b24, b34, b44}
    {
      Vec4f.dot(a1, b1), Vec4f.dot(a1, b2), Vec4f.dot(a1, b3), Vec4f.dot(a1, b4),
      Vec4f.dot(a2, b1), Vec4f.dot(a2, b2), Vec4f.dot(a2, b3), Vec4f.dot(a2, b4),
      Vec4f.dot(a3, b1), Vec4f.dot(a3, b2), Vec4f.dot(a3, b3), Vec4f.dot(a3, b4),
      Vec4f.dot(a4, b1), Vec4f.dot(a4, b2), Vec4f.dot(a4, b3), Vec4f.dot(a4, b4)
    }
  end

  # ------------------
  # matrix application
  # ------------------

  @doc """
  Multiply a matrix times a vector.

  The vector must have the same dimension 
  as the number of columns in the matrix.

  Multiplication is implemented by successive dot products
  of row-vectors in the matrix with the vector.
  """
  @spec xform(S.matrix(), tuple()) :: S.matrix()

  def xform(:iden22, v) when is_vec2f(v), do: v

  def xform({
        a11, a12,
        a21, a22
      }, 
      b) when is_vec2f(b) do
    {
      Vec2f.dot({a11, a12}, b),
      Vec2f.dot({a21, a22}, b), 
    }
  end

  def xform(:iden33, v) when is_vec3f(v), do: v

  def xform({
        a11, a12, a13,
        a21, a22, a23,
        a31, a32, a33
      },
      b) when is_vec3f(b) do
    {
      Vec3f.dot({a11, a12, a13}, b), 
      Vec3f.dot({a21, a22, a23}, b), 
      Vec3f.dot({a31, a32, a33}, b)
    }
  end

  def xform(:iden44, v) when is_vec4f(v), do: v

  def xform({
        a11, a12, a13, a14,
        a21, a22, a23, a24,
        a31, a32, a33, a34,
        a41, a42, a43, a44
      },
      b) when is_vec4f(b) do
    {
      Vec4f.dot({a11, a12, a13, a14}, b),
      Vec4f.dot({a21, a22, a23, a24}, b), 
      Vec4f.dot({a31, a32, a33, a34}, b),
      Vec4f.dot({a41, a42, a43, a44}, b),
    }
  end
end
