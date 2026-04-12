//// 2x2 matrices of floats

import gleam/float
import gleam/list
import gleam/result
import gleam_community/maths
import vec/vec2.{type Vec2, Vec2}
import vec/vec2f.{type Vec2f, positive_x, positive_y}

/// Mat2f is a 2x2 column-major matrix of `Float`s.
pub type Mat2f =
  Vec2(Vec2f)

/// A Mat2f with all elements set to `0.0`
pub const zero: Mat2f = vec2.Vec2(vec2f.zero, vec2f.zero)

/// A Mat2f representing the identity, i.e. `1.0` is on the diagonal.
pub const identity: Mat2f = vec2.Vec2(positive_x, positive_y)

/// Constructs a `Mat2f` from its components:
/// ```text
/// | a  c |
/// | b  d |
/// ```
pub fn new(a: Float, b: Float, c: Float, d: Float) -> Mat2f {
  Vec2(Vec2(a, b), Vec2(c, d))
}

/// Constructs a `Mat2f` from its two columns.
/// ```text
/// | ax  bx |
/// | ay  by |
/// ```
pub fn from_cols(a: Vec2f, b: Vec2f) -> Mat2f {
  Vec2(a, b)
}

/// Constructs a `Mat2f` with the given diagonal and all other entries set to 0.
/// ```text
/// | x    0.0 |
/// | 0.0  y   |
/// ```
pub fn from_diagonal(diag: Vec2f) -> Mat2f {
  new(diag.x, 0.0, 0.0, diag.y)
}

/// Constructs a `Mat2f` from scale factor (as a `Vec2f`) and a rotation in radians.
pub fn from_scale_angle(scale: Vec2f, angle: Float) -> Mat2f {
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  new(cos *. scale.x, sin *. scale.x, -1.0 *. sin *. scale.y, cos *. scale.y)
}

/// Constructs a `Mat2f` from a rotation angle in radians.
pub fn from_angle(angle: Float) -> Mat2f {
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  new(cos, sin, -1.0 *. sin, cos)
}

/// Transposes the `Mat2f` along the diagonal.
pub fn transpose(mat: Mat2f) -> Mat2f {
  new(mat.x.x, mat.y.x, mat.x.y, mat.y.y)
}

/// Returns the diagonal of the `Mat2f`
pub fn diagonal(mat: Mat2f) -> Vec2f {
  Vec2(mat.x.x, mat.y.y)
}

/// Returns the determinant for the `Mat2f`.
pub fn determinant(mat: Mat2f) -> Float {
  mat.x.x *. mat.y.y -. mat.x.y *. mat.y.x
}

/// Inverts the `Mat2f`, returning an error if the determinant is zero.
pub fn inverse(mat: Mat2f) -> Result(Mat2f, Nil) {
  use inv_det <- result.map(float.divide(1.0, determinant(mat)))
  new(
    mat.y.y *. inv_det,
    mat.x.y *. inv_det *. -1.0,
    mat.y.x *. inv_det *. -1.0,
    mat.x.x *. inv_det,
  )
}

/// Transforms a `Vec2f` by this `Mat2f`.
pub fn mul_vec2(mat: Mat2f, rhs: Vec2f) -> Vec2f {
  Vec2(
    mat.x.x *. rhs.x +. mat.y.x *. rhs.y,
    mat.x.y *. rhs.x +. mat.y.y *. rhs.y,
  )
}

/// Transforms a `Vec2f` by the transpose of this `Mat2f`.
pub fn mul_transpose_vec2(mat: Mat2f, rhs: Vec2f) -> Vec2f {
  vec2.map(mat, vec2f.dot(_, rhs))
}

/// Negates all elements of the `Mat2f`
pub fn negate(mat: Mat2f) -> Mat2f {
  vec2.map(mat, vec2f.negate)
}

/// Takes the absolute value of each element in the `Mat2f`.
pub fn absolute_value(mat: Mat2f) -> Mat2f {
  vec2.map(mat, vec2f.absolute_value)
}

/// Adds two `Mat2f` together.
pub fn add(a: Mat2f, b: Mat2f) -> Mat2f {
  vec2.map2(a, b, vec2f.add)
}

/// Subtracts one `Mat2f` from the other.
pub fn subtract(a: Mat2f, b: Mat2f) -> Mat2f {
  vec2.map2(a, b, vec2f.subtract)
}

/// Multiplies two `Mat2f` together.
pub fn multiply(a: Mat2f, b: Mat2f) -> Mat2f {
  vec2.map(b, mul_vec2(a, _))
}

/// Divides one `Mat2f` by another. Equivalent to multiplying the inverse of the second matrix.
pub fn divide(a: Mat2f, b: Mat2f) -> Result(Mat2f, Nil) {
  use inv_b <- result.map(inverse(b))
  multiply(a, inv_b)
}

/// Scales the `Mat2f` by a `Float` factor.
pub fn scale(mat: Mat2f, scale: Float) -> Mat2f {
  vec2.map(mat, vec2f.scale(_, scale))
}

/// Scales the `Mat2f` by a `Vec2f`.
///
/// This is faster than creating a diagonal scaling matrix and then multiplying that.
pub fn scale_diagonal(mat: Mat2f, scale: Vec2f) -> Mat2f {
  vec2.map2(mat, scale, vec2f.scale)
}

/// Returns a matrix containing the reciprocal of each element of the `Mat2f`.
///
/// If any of the elements is zero, an error is returned.
pub fn reciprocal(mat: Mat2f) -> Result(Mat2f, Nil) {
  vec2.map(mat, fn(column) {
    column
    |> vec2.map(float.divide(1.0, _))
    |> vec2.result()
  })
  |> vec2.result
}

/// Sums a list of `Mat2f`s.
pub fn sum(mats: List(Mat2f)) -> Mat2f {
  list.fold(mats, zero, add)
}

/// Multiplies a list of `Mat2f`s.
pub fn product(mats: List(Mat2f)) -> Mat2f {
  list.fold(mats, identity, multiply)
}
