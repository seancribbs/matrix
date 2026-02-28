//// 4x4 matrices of floats

import vec/vec4.{type Vec4, Vec4}
import vec/vec4f.{type Vec4f}

/// Mat4f is a 4x4 column-major matrix of `Float`s.
pub type Mat4f =
  Vec4(Vec4f)

/// A 4x4 matrix filled with zeroes.
pub const zero: Mat4f = Vec4(vec4f.zero, vec4f.zero, vec4f.zero, vec4f.zero)

const x: Vec4f = Vec4(1.0, 0.0, 0.0, 0.0)

const y: Vec4f = Vec4(0.0, 1.0, 0.0, 0.0)

const z: Vec4f = Vec4(0.0, 0.0, 1.0, 0.0)

const w: Vec4f = Vec4(0.0, 0.0, 0.0, 1.0)

/// The 4x4 identity matrix
pub const identity: Mat4f = Vec4(x, y, z, w)

/// Constructs a `Mat4f` from its components.
/// ```text
/// | ax  bx  cx  dx |
/// | ay  by  cy  dy |
/// | az  bz  cz  dz |
/// | aw  bw  cw  dw |
/// ```
pub fn new(
  ax: Float,
  ay: Float,
  az: Float,
  aw: Float,
  bx: Float,
  by: Float,
  bz: Float,
  bw: Float,
  cx: Float,
  cy: Float,
  cz: Float,
  cw: Float,
  dx: Float,
  dy: Float,
  dz: Float,
  dw: Float,
) -> Mat4f {
  Vec4(
    Vec4(ax, ay, az, aw),
    Vec4(bx, by, bz, bw),
    Vec4(cx, cy, cz, cw),
    Vec4(dx, dy, dz, dw),
  )
}

/// Constructs a `Mat4f` from its four columns.
/// ```text
/// | a.x  b.x  c.x  d.x |
/// | a.y  b.y  c.y  d.y |
/// | a.z  b.z  c.z  d.z |
/// | a.w  b.w  c.w  d.w |
/// ```
pub fn from_cols(a: Vec4f, b: Vec4f, c: Vec4f, d: Vec4f) -> Mat4f {
  Vec4(a, b, c, d)
}

/// Creates a 4x4 matrix with its diagonal set to `diagonal` and all other entries are 0.
pub fn from_diagonal(diagonal: Vec4f) -> Mat4f {
  from_cols(
    Vec4(diagonal.x, 0.0, 0.0, 0.0),
    Vec4(0.0, diagonal.y, 0.0, 0.0),
    Vec4(0.0, 0.0, diagonal.z, 0.0),
    Vec4(0.0, 0.0, 0.0, diagonal.w),
  )
}

/// Transposes the `Mat4f` along the diagonal.
pub fn transpose(mat: Mat4f) -> Mat4f {
  from_cols(
    Vec4(mat.x.x, mat.y.x, mat.z.x, mat.w.x),
    Vec4(mat.x.y, mat.y.y, mat.z.y, mat.w.y),
    Vec4(mat.x.z, mat.y.z, mat.z.z, mat.w.z),
    Vec4(mat.x.w, mat.y.w, mat.z.w, mat.w.w),
  )
}

/// Extracts the diagonal of the `Mat4f`.
pub fn diagonal(mat: Mat4f) -> Vec4f {
  Vec4(mat.x.x, mat.y.y, mat.z.z, mat.w.w)
}

/// Returns the determinant of the `Mat4f`.
pub fn determinant(mat: Mat4f) -> Float {
  let Vec4(x: m00, y: m01, z: m02, w: m03) = mat.x
  let Vec4(x: m10, y: m11, z: m12, w: m13) = mat.y
  let Vec4(x: m20, y: m21, z: m22, w: m23) = mat.z
  let Vec4(x: m30, y: m31, z: m32, w: m33) = mat.w

  let a2323 = m22 *. m33 -. m23 *. m32
  let a1323 = m21 *. m33 -. m23 *. m31
  let a1223 = m21 *. m32 -. m22 *. m31
  let a0323 = m20 *. m33 -. m23 *. m30
  let a0223 = m20 *. m32 -. m22 *. m30
  let a0123 = m20 *. m31 -. m21 *. m30

  m00
  *. { m11 *. a2323 -. m12 *. a1323 +. m13 *. a1223 }
  -. m01
  *. { m10 *. a2323 -. m12 *. a0323 +. m13 *. a0223 }
  +. m02
  *. { m10 *. a1323 -. m11 *. a0323 +. m13 *. a0123 }
  -. m03
  *. { m10 *. a1223 -. m11 *. a0223 +. m12 *. a0123 }
}

/// Transforms a 4D vector by this `Mat4f`.
pub fn mul_vec4(mat: Mat4f, rhs: Vec4f) -> Vec4f {
  vec4.map2(mat, rhs, vec4f.scale)
  |> vec4.to_list
  |> vec4f.sum
}

/// Transforms a 4D vector by the transpose of the `Mat4f`.
///
/// Equivalent to matrix multiplication where the vector is on the left.
pub fn mul_transpose_vec4(mat: Mat4f, rhs: Vec4f) -> Vec4f {
  vec4.map(mat, vec4f.dot(_, rhs))
}

/// Scales the `Mat4f` by a `Float`.
pub fn scale(mat: Mat4f, scale: Float) -> Mat4f {
  vec4.map(mat, vec4f.scale(_, scale))
}

/// Adds two `Mat4f`s together
pub fn add(a: Mat4f, b: Mat4f) -> Mat4f {
  vec4.map2(a, b, vec4f.add)
}

/// Subtracts `Mat4f` `b` from `a`
pub fn subtract(a: Mat4f, b: Mat4f) -> Mat4f {
  vec4.map2(a, b, vec4f.subtract)
}
