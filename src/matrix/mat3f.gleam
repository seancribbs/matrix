//// 3x3 matrices of floats

import gleam/float
import gleam/list
import gleam/result
import gleam_community/maths
import matrix/internal/projection.{extend2, to_xy, to_xz, to_yz}
import matrix/mat2f
import vec/vec2
import vec/vec2f.{type Vec2f}
import vec/vec3.{type Vec3, Vec3}
import vec/vec3f.{type Vec3f, positive_x, positive_y, positive_z}
import vec/vec4f

/// Mat3f is a 3x3 column-major matrix of `Float`s.
pub type Mat3f =
  Vec3(Vec3f)

/// A Mat3f with all elements set to `0.0`
pub const zero: Mat3f = vec3.Vec3(vec3f.zero, vec3f.zero, vec3f.zero)

/// A Mat3f representing the identity, i.e. `1.0` is on the diagonal.
pub const identity: Mat3f = vec3.Vec3(positive_x, positive_y, positive_z)

/// Constructs a `Mat3f` from its components:
/// ```text
/// | a  d  g |
/// | b  e  h |
/// | c  f  i |
/// ```
pub fn new(
  a: Float,
  b: Float,
  c: Float,
  d: Float,
  e: Float,
  f: Float,
  g: Float,
  h: Float,
  i: Float,
) -> Mat3f {
  Vec3(Vec3(a, b, c), Vec3(d, e, f), Vec3(g, h, i))
}

/// Constructs a `Mat3f` from its three columns.
/// ```text
/// | ax  bx  cx |
/// | ay  by  cy |
/// | az  bz  cz |
/// ```
pub fn from_cols(a: Vec3f, b: Vec3f, c: Vec3f) -> Mat3f {
  Vec3(a, b, c)
}

/// Constructs a `Mat3f` with the given diagonal and all other entries set to 0.
/// ```text
/// | x    0.0  0.0 |
/// | 0.0  y    0.0 |
/// | 0.0  0.0  z   |
/// ```
pub fn from_diagonal(diag: Vec3f) -> Mat3f {
  new(diag.x, 0.0, 0.0, 0.0, diag.y, 0.0, 0.0, 0.0, diag.z)
}

/// Constructs a 3D rotation matrix from the given quaternion, represented as a `vec4.Vec4(Float)`.
pub fn from_quaternion(q: vec4f.Vec4f) -> Mat3f {
  let rotation = vec4f.normalize(q)

  let x2 = rotation.x +. rotation.x
  let y2 = rotation.y +. rotation.y
  let z2 = rotation.z +. rotation.z
  let xx = rotation.x *. x2
  let xy = rotation.x *. y2
  let xz = rotation.x *. z2
  let yy = rotation.y *. y2
  let yz = rotation.y *. z2
  let zz = rotation.z *. z2
  let wx = rotation.w *. x2
  let wy = rotation.w *. y2
  let wz = rotation.w *. z2

  from_cols(
    Vec3(1.0 -. { yy +. zz }, xy +. wz, xz -. wy),
    Vec3(xy -. wz, 1.0 -. { xx +. zz }, yz +. wx),
    Vec3(xz +. wy, yz -. wx, 1.0 -. { xx +. yy }),
  )
}

/// Creates a 3D rotation matrix from a normalized rotation `axis` and `angle` (in radians).
pub fn from_axis_angle(axis: Vec3f, angle: Float) -> Mat3f {
  let axis = vec3f.normalize(axis)
  let sin_a = maths.sin(angle)
  let cos_a = maths.cos(angle)
  let Vec3(x:, y:, z:) = axis
  let Vec3(x: xsin, y: ysin, z: zsin) = vec3f.scale(axis, sin_a)
  let Vec3(x: x2, y: y2, z: z2) = vec3f.multiply(axis, axis)
  let omc = 1.0 -. cos_a
  let xyomc = x *. y *. omc
  let xzomc = x *. z *. omc
  let yzomc = y *. z *. omc
  from_cols(
    Vec3(x2 *. omc +. cos_a, xyomc +. zsin, yzomc -. ysin),
    Vec3(xyomc -. zsin, y2 *. omc +. cos_a, yzomc +. xsin),
    Vec3(xzomc +. ysin, yzomc -. xsin, z2 *. omc +. cos_a),
  )
}

/// Creates a 3D rotation matrix from `angle` in radians around the x axis.
pub fn from_rotation_x(angle: Float) -> Mat3f {
  let sina = maths.sin(angle)
  let cosa = maths.cos(angle)
  from_cols(positive_x, Vec3(0.0, cosa, sina), Vec3(0.0, 0.0 -. sina, cosa))
}

/// Creates a 3D rotation matrix from `angle` in radians around the y axis.
pub fn from_rotation_y(angle: Float) -> Mat3f {
  let sina = maths.sin(angle)
  let cosa = maths.cos(angle)
  from_cols(Vec3(cosa, 0.0, 0.0 -. sina), positive_y, Vec3(sina, 0.0, cosa))
}

/// Creates a 3D rotation matrix from `angle` in radians around the z axis.
pub fn from_rotation_z(angle: Float) -> Mat3f {
  let sina = maths.sin(angle)
  let cosa = maths.cos(angle)
  from_cols(Vec3(cosa, sina, 0.0), Vec3(0.0 -. sina, cosa, 0.0), positive_z)
}

/// Creates an affine transformation matrix from the given 2D `translation`.
///
/// The resulting matrix can be used to transform 2D points and vectors.
pub fn from_translation(translation: vec2f.Vec2f) -> Mat3f {
  from_cols(positive_x, positive_y, extend2(translation, 1.0))
}

/// Creates an affine transformation matrix from the given 2D rotation `angle` (in radians).
///
/// The resulting matrix can be used to transform 2D points and vectors.
pub fn from_angle(angle: Float) -> Mat3f {
  from_rotation_z(angle)
}

/// Creates an affine transformation matrix from the given 2D `scale`, rotation `angle` (in radians), and `translation`.
///
/// The resulting matrix can be used to transform 2D points and vectors.
pub fn from_scale_angle_translation(
  scale: Vec2f,
  angle: Float,
  translation: Vec2f,
) -> Mat3f {
  let sina = maths.sin(angle)
  let cosa = maths.cos(angle)
  from_cols(
    Vec3(cosa *. scale.x, sina *. scale.x, 0.0),
    Vec3(float.negate(sina) *. scale.y, cosa *. scale.y, 0.0),
    extend2(translation, 1.0),
  )
}

/// Creates an affine transformation matrix from teh given non-uniform 2D `scale`.
///
/// The resulting matrix can be used to transform 2D points and vectors.
pub fn from_scale(scale: Vec2f) -> Mat3f {
  from_diagonal(extend2(scale, 1.0))
}

/// Transposes the `Mat3f` along the diagonal.
pub fn transpose(mat: Mat3f) -> Mat3f {
  new(
    mat.x.x,
    mat.y.x,
    mat.z.x,
    mat.x.y,
    mat.y.y,
    mat.z.y,
    mat.x.z,
    mat.y.z,
    mat.z.z,
  )
}

/// Returns the determinant for the `Mat3f`.
pub fn determinant(mat: Mat3f) -> Float {
  let Vec3(Vec3(a1, b1, c1), Vec3(a2, b2, c2), Vec3(a3, b3, c3)) = mat
  { a1 *. b2 *. c3 }
  -. { a1 *. b3 *. c2 }
  -. { a2 *. b1 *. c3 }
  +. { a2 *. b3 *. c1 }
  +. { a3 *. b1 *. c2 }
  -. { a3 *. b2 *. c1 }
}

/// Inverts the `Mat3f`, returning an error if the determinant is zero.
pub fn inverse(mat: Mat3f) -> Result(Mat3f, Nil) {
  use inv_det <- result.map(float.divide(1.0, determinant(mat)))

  // Reference: https://mathworld.wolfram.com/MatrixInverse.html
  //
  // The below is not the most efficient form (we could extract the individual
  // components and inline the multiplication), but it is the most direct mapping
  // to what the Reference above states, nine determinants based on projections
  // of the original matrix.
  let xx = mat |> to_yz |> vec2.map(to_yz) |> mat2f.determinant
  let xy = mat |> to_xz |> vec2.map(to_yz) |> vec2.swap |> mat2f.determinant
  let xz = mat |> to_xy |> vec2.map(to_yz) |> mat2f.determinant

  let yx = mat |> to_yz |> vec2.map(to_xz) |> vec2.swap |> mat2f.determinant
  let yy = mat |> to_xz |> vec2.map(to_xz) |> mat2f.determinant
  let yz = mat |> to_xy |> vec2.map(to_xz) |> vec2.swap |> mat2f.determinant

  let zx = mat |> to_yz |> vec2.map(to_xy) |> mat2f.determinant
  let zy = mat |> to_xz |> vec2.map(to_xy) |> vec2.swap |> mat2f.determinant
  let zz = mat |> to_xy |> vec2.map(to_xy) |> mat2f.determinant

  scale(new(xx, xy, xz, yx, yy, yz, zx, zy, zz), inv_det)
}

/// Transforms a `Vec3f` by this `Mat3f`.
pub fn mul_vec3(mat: Mat3f, rhs: Vec3f) -> Vec3f {
  vec3.map2(mat, rhs, vec3f.scale)
  |> vec3.to_list
  |> vec3f.sum
}

/// Transforms the given 2D vector as a point.
///
/// This is the equivalent of multiplying `rhs` as a 3D vector where `z` is `1`.
///
/// This function assumes that `mat` contains a valid affine transform.
pub fn transform_point2(mat: Mat3f, rhs: Vec2f) -> Vec2f {
  mat2f.from_cols(to_xy(mat.x), to_xy(mat.y))
  |> mat2f.mul_transpose_vec2(rhs)
  |> vec2f.add(to_xy(mat.z))
}

/// Rotates the given 2D vector.
///
/// This is the equivalent of multiplying `rhs` as a 3D vector where `z` is `0`.
pub fn transform_vector2(mat: Mat3f, rhs: Vec2f) -> Vec2f {
  mat2f.from_cols(to_xy(mat.x), to_xy(mat.y))
  |> mat2f.mul_transpose_vec2(rhs)
}

/// Creates a left-handed view matrix using a facing direction and an up direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up`, and `+Z=forward`.
pub fn look_to_lh(dir: Vec3f, up: Vec3f) -> Mat3f {
  look_to_rh(vec3f.negate(dir), up)
}

/// Creates a right-handed view matrix using a facing direction and an up direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=back`.
pub fn look_to_rh(dir: Vec3f, up: Vec3f) {
  let up = vec3f.normalize(up)
  let f = vec3f.normalize(dir)
  let s = f |> vec3f.cross(up) |> vec3f.normalize
  let u = vec3f.cross(s, f)
  let neg_f = vec3f.negate(f)

  from_cols(
    Vec3(s.x, u.x, neg_f.x),
    Vec3(s.y, u.y, neg_f.y),
    Vec3(s.z, u.z, neg_f.z),
  )
}

/// Creates a left-handed view matrix using a camera position, a focal point and an up
/// direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=forward`.
pub fn look_at_lh(eye: Vec3f, center: Vec3f, up: Vec3f) -> Mat3f {
  look_to_lh(vec3f.subtract(center, eye), up)
}

/// Creates a right-handed view matrix using a camera position, a focal point and an up
/// direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=back`.
pub fn look_at_rh(eye: Vec3f, center: Vec3f, up: Vec3f) -> Mat3f {
  look_to_rh(vec3f.subtract(center, eye), up)
}

/// Transforms a `Vec3f` by the transpose of this `Mat3f`.
pub fn mul_transpose_vec3(mat: Mat3f, rhs: Vec3f) -> Vec3f {
  vec3.map(mat, vec3f.dot(_, rhs))
}

/// Negates all elements of the `Mat3f`
pub fn negate(mat: Mat3f) -> Mat3f {
  vec3.map(mat, vec3f.negate)
}

/// Takes the absolute value of each element in the `Mat3f`.
pub fn absolute_value(mat: Mat3f) -> Mat3f {
  vec3.map(mat, vec3f.absolute_value)
}

/// Adds two `Mat3f` together.
pub fn add(a: Mat3f, b: Mat3f) -> Mat3f {
  vec3.map2(a, b, vec3f.add)
}

/// Subtracts one `Mat3f` from the other.
pub fn subtract(a: Mat3f, b: Mat3f) -> Mat3f {
  vec3.map2(a, b, vec3f.subtract)
}

/// Multiplies two `Mat3f` together.
pub fn multiply(a: Mat3f, b: Mat3f) -> Mat3f {
  vec3.map(b, mul_vec3(a, _))
}

/// Divides one `Mat3f` by another. Equivalent to multiplying the inverse of the second matrix.
pub fn divide(a: Mat3f, b: Mat3f) -> Result(Mat3f, Nil) {
  use inv_b <- result.map(inverse(b))
  multiply(a, inv_b)
}

/// Scales the `Mat3f` by a `Float` factor.
pub fn scale(mat: Mat3f, scale: Float) -> Mat3f {
  vec3.map(mat, vec3f.scale(_, scale))
}

/// Scales the `Mat3f` by a `Vec3f`.
///
/// This is faster than creating a diagonal scaling matrix and then multiplying that.
pub fn scale_diagonal(mat: Mat3f, scale: Vec3f) -> Mat3f {
  vec3.map2(mat, scale, vec3f.scale)
}

/// Returns a matrix containing the reciprocal of each element of the `Mat3f`.
///
/// If any of the elements is zero, an error is returned.
pub fn reciprocal(mat: Mat3f) -> Result(Mat3f, Nil) {
  vec3.map(mat, fn(column) {
    column
    |> vec3.map(float.divide(1.0, _))
    |> vec3.result
  })
  |> vec3.result
}

/// Sums a list of `Mat3f`s.
pub fn sum(mats: List(Mat3f)) -> Mat3f {
  list.fold(mats, zero, add)
}

/// Multiplies a list of `Mat3f`s.
pub fn product(mats: List(Mat3f)) -> Mat3f {
  list.fold(mats, identity, multiply)
}
