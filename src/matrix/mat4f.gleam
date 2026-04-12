//// 4x4 matrices of floats

import gleam/bool
import gleam/float
import gleam/result
import gleam_community/maths
import matrix/internal/projection.{extend3, to_xyz}
import matrix/mat3f
import vec/vec3.{Vec3}
import vec/vec3f.{type Vec3f}
import vec/vec4.{type Vec4, Vec4}
import vec/vec4f.{type Vec4f, positive_w, positive_x, positive_y, positive_z}

/// Mat4f is a 4x4 column-major matrix of `Float`s.
pub type Mat4f =
  Vec4(Vec4f)

/// A 4x4 matrix filled with zeroes.
pub const zero: Mat4f = Vec4(vec4f.zero, vec4f.zero, vec4f.zero, vec4f.zero)

/// The 4x4 identity matrix
pub const identity: Mat4f = Vec4(positive_x, positive_y, positive_z, positive_w)

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

/// Creates an affine transformation matrix from the given 3D `scale`, `rotation` and
/// `translation`.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_scale_rotation_translation(
  scale: Vec3f,
  rotation: Vec4f,
  translation: Vec3f,
) -> Mat4f {
  let axes =
    rotation
    |> quat_to_axes
    |> vec3.map2(scale, vec4f.scale)

  from_cols(axes.x, axes.y, axes.z, extend3(translation, 1.0))
}

/// Creates an affine transformation matrix from the given 3D `translation`.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_rotation_translation(rotation: Vec4f, translation: Vec3f) -> Mat4f {
  from_scale_rotation_translation(vec3f.one, rotation, translation)
}

/// Extracts `scale`, `rotation` and `translation` from `mat`. The input matrix is
/// expected to be a 3D affine transformation matrix otherwise the output will be invalid.
///
/// Will return `Error(Nil)` if the determinant of `mat` is zero or if the resulting scale vector
/// contains any zero elements.
pub fn to_scale_rotation_translation(
  mat: Mat4f,
) -> Result(#(Vec3f, Vec4f, Vec3f), Nil) {
  let det = determinant(mat)
  use signum <- result.try(float.divide(det, float.absolute_value(det)))

  let scale =
    Vec3(
      vec4f.length(mat.x) *. signum,
      vec4f.length(mat.y),
      vec4f.length(mat.z),
    )

  use <- bool.guard(
    when: !vec3f.loosely_equals(scale, vec3f.zero, 0.0000001),
    return: Error(Nil),
  )

  use inv_scale <- result.map(
    scale |> vec3.map(float.divide(1.0, _)) |> vec3.result,
  )

  let rotation =
    quat_from_rotation_axes(
      mat.x |> vec4f.scale(inv_scale.x) |> to_xyz,
      mat.y |> vec4f.scale(inv_scale.y) |> to_xyz,
      mat.z |> vec4f.scale(inv_scale.z) |> to_xyz,
    )

  #(scale, rotation, to_xyz(mat.w))
}

/// Creates an affine transformation matrix from the given `rotation` quaternion.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_quaternion(q: Vec4f) -> Mat4f {
  let rotation = quat_to_axes(q)
  from_cols(rotation.x, rotation.y, rotation.z, positive_w)
}

/// Creates an affine transformation matrix from the given 3x3 linear transformation
/// matrix.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_mat3(m: mat3f.Mat3f) -> Mat4f {
  from_cols(extend3(m.x, 0.0), extend3(m.y, 0.0), extend3(m.z, 0.0), positive_w)
}

/// Creates an affine transformation matrics from a 3x3 matrix (expressing scale, shear and
/// rotation) and a translation vector.
///
/// Equivalent to `multiply(from_translation(translation), from_mat3(mat3))`
pub fn from_mat3_translation(mat3: mat3f.Mat3f, translation: Vec3f) -> Mat4f {
  from_cols(
    extend3(mat3.x, 0.0),
    extend3(mat3.y, 0.0),
    extend3(mat3.z, 0.0),
    extend3(translation, 1.0),
  )
}

/// Creates an affine transformation matrix from the given 3D `translation`.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_translation(translation: Vec3f) -> Mat4f {
  from_cols(positive_x, positive_y, positive_z, extend3(translation, 1.0))
}

/// Creates an affine transformation matrix containing a 3D rotation around a normalized
/// rotation `axis` of `angle` (in radians).
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_axis_angle(axis: Vec3f, angle: Float) -> Mat4f {
  let axis = vec3f.normalize(axis)
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  let axis_sin = vec3f.scale(axis, sin)
  let axis_sq = vec3f.multiply(axis, axis)
  let omc = 1.0 -. cos
  let xyomc = axis.x *. axis.y *. omc
  let xzomc = axis.x *. axis.z *. omc
  let yzomc = axis.y *. axis.z *. omc
  from_cols(
    Vec4(axis_sq.x *. omc +. cos, xyomc +. axis_sin.z, xzomc -. axis_sin.y, 0.0),
    Vec4(xyomc -. axis_sin.z, axis_sq.y *. omc +. cos, yzomc +. axis_sin.x, 0.0),
    Vec4(xzomc +. axis_sin.y, yzomc -. axis_sin.x, axis_sq.z *. omc +. cos, 0.0),
    positive_w,
  )
}

/// Creates an affine transformation matrix containing a 3D rotation around the x axis of
/// `angle` (in radians).
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_rotation_x(angle: Float) -> Mat4f {
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  from_cols(
    positive_x,
    Vec4(0.0, cos, sin, 0.0),
    Vec4(0.0, 0.0 -. sin, cos, 0.0),
    positive_w,
  )
}

/// Creates an affine transformation matrix containing a 3D rotation around the y axis of
/// `angle` (in radians).
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_rotation_y(angle: Float) -> Mat4f {
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  from_cols(
    Vec4(cos, 0.0, 0.0 -. sin, 0.0),
    positive_y,
    Vec4(sin, 0.0, cos, 0.0),
    positive_w,
  )
}

/// Creates an affine transformation matrix containing a 3D rotation around the z axis of
/// `angle` (in radians).
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_rotation_z(angle: Float) -> Mat4f {
  let sin = maths.sin(angle)
  let cos = maths.cos(angle)
  from_cols(
    Vec4(cos, sin, 0.0, 0.0),
    Vec4(0.0 -. sin, cos, 0.0, 0.0),
    positive_z,
    positive_w,
  )
}

/// Creates an affine transformation matrix containing the given 3D non-uniform `scale`.
///
/// The resulting matrix can be used to transform 3D points and vectors.
pub fn from_scale(scale: Vec3f) -> Mat4f {
  from_diagonal(extend3(scale, 1.0))
}

/// Inverts the `Mat4f`, returning an error if the matrix is not invertible.
pub fn inverse(mat: Mat4f) -> Result(Mat4f, Nil) {
  let Vec4(
    Vec4(m00, m01, m02, m03),
    Vec4(m10, m11, m12, m13),
    Vec4(m20, m21, m22, m23),
    Vec4(m30, m31, m32, m33),
  ) = mat

  let coef00 = m22 *. m33 -. m32 *. m23
  let coef02 = m12 *. m33 -. m32 *. m13
  let coef03 = m12 *. m23 -. m22 *. m13
  let coef04 = m21 *. m33 -. m31 *. m23
  let coef06 = m11 *. m33 -. m31 *. m13
  let coef07 = m11 *. m23 -. m21 *. m13
  let coef08 = m21 *. m32 -. m31 *. m22
  let coef10 = m11 *. m32 -. m31 *. m12
  let coef11 = m11 *. m22 -. m21 *. m12
  let coef12 = m20 *. m33 -. m30 *. m23
  let coef14 = m10 *. m33 -. m30 *. m13
  let coef15 = m10 *. m23 -. m20 *. m13
  let coef16 = m20 *. m32 -. m30 *. m22
  let coef18 = m10 *. m32 -. m30 *. m12
  let coef19 = m10 *. m22 -. m20 *. m12
  let coef20 = m20 *. m31 -. m30 *. m21
  let coef22 = m10 *. m31 -. m30 *. m11
  let coef23 = m10 *. m21 -. m20 *. m11

  let fac0 = Vec4(coef00, coef00, coef02, coef03)
  let fac1 = Vec4(coef04, coef04, coef06, coef07)
  let fac2 = Vec4(coef08, coef08, coef10, coef11)
  let fac3 = Vec4(coef12, coef12, coef14, coef15)
  let fac4 = Vec4(coef16, coef16, coef18, coef19)
  let fac5 = Vec4(coef20, coef20, coef22, coef23)

  let vec0 = Vec4(m10, m00, m00, m00)
  let vec1 = Vec4(m11, m01, m01, m01)
  let vec2 = Vec4(m12, m02, m02, m02)
  let vec3 = Vec4(m13, m03, m03, m03)

  let inv0 =
    vec1
    |> vec4f.multiply(fac0)
    |> vec4f.subtract(vec2 |> vec4f.multiply(fac1))
    |> vec4f.add(vec3 |> vec4f.multiply(fac2))
  let inv1 =
    vec0
    |> vec4f.multiply(fac0)
    |> vec4f.subtract(vec2 |> vec4f.multiply(fac3))
    |> vec4f.add(vec3 |> vec4f.multiply(fac4))
  let inv2 =
    vec0
    |> vec4f.multiply(fac1)
    |> vec4f.subtract(vec1 |> vec4f.multiply(fac3))
    |> vec4f.add(vec3 |> vec4f.multiply(fac5))
  let inv3 =
    vec0
    |> vec4f.multiply(fac2)
    |> vec4f.subtract(vec1 |> vec4f.multiply(fac4))
    |> vec4f.add(vec2 |> vec4f.multiply(fac5))

  let sign_a = Vec4(1.0, -1.0, 1.0, -1.0)
  let sign_b = Vec4(-1.0, 1.0, -1.0, 1.0)

  let inverse =
    from_cols(
      inv0 |> vec4f.multiply(sign_a),
      inv1 |> vec4f.multiply(sign_b),
      inv2 |> vec4f.multiply(sign_a),
      inv3 |> vec4f.multiply(sign_b),
    )

  let col0 = Vec4(inverse.x.x, inverse.y.x, inverse.z.x, inverse.w.x)

  let dot0 = mat.x |> vec4f.multiply(col0)
  let dot1 = dot0.x +. dot0.y +. dot0.z +. dot0.w

  result.map(float.divide(1.0, dot1), scale(inverse, _))
}

/// Creates a left-handed view matrix using a camera position, a facing direction and an up
/// direction
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=forward`.
pub fn look_to_lh(eye: Vec3f, dir: Vec3f, up: Vec3f) -> Mat4f {
  look_to_rh(eye, vec3f.negate(dir), up)
}

/// Creates a right-handed view matrix using a camera position, a facing direction, and an up
/// direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=back`.
pub fn look_to_rh(eye: Vec3f, dir: Vec3f, up: Vec3f) -> Mat4f {
  let f = dir
  let s = vec3f.cross(f, up) |> vec3f.normalize()
  let u = vec3f.cross(s, f)
  let neg_f = vec3f.negate(f)
  let neg_dot_s = float.negate(vec3f.dot(eye, s))
  let neg_dot_u = float.negate(vec3f.dot(eye, u))
  let dot_f = vec3f.dot(eye, f)

  from_cols(
    Vec4(s.x, u.x, neg_f.x, 0.0),
    Vec4(s.y, u.y, neg_f.y, 0.0),
    Vec4(s.z, u.z, neg_f.z, 0.0),
    Vec4(neg_dot_s, neg_dot_u, dot_f, 1.0),
  )
}

/// Creates a left-handed view matrix using a camera position, a focal points and an up
/// direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=forward`.
pub fn look_at_lh(eye: Vec3f, center: Vec3f, up: Vec3f) -> Mat4f {
  look_to_lh(eye, center |> vec3f.subtract(eye) |> vec3f.normalize(), up)
}

/// Creates a right-handed view matrix using a camera position, a focal point, and an up
/// direction.
///
/// For a view coordinate system with `+X=right`, `+Y=up` and `+Z=back`.
pub fn look_at_rh(eye: Vec3f, center: Vec3f, up: Vec3f) -> Mat4f {
  look_to_rh(eye, center |> vec3f.subtract(eye) |> vec3f.normalize(), up)
}

/// Transforms the given 3D vector as a point.
///
/// This is the equivalent of multiplying the 3D vector as a 4D vector where `w` is
/// `1.0`.
///
/// This function assumes that `mat` contains a valid affine transform.
pub fn transform_point3(mat: Mat4f, rhs: Vec3f) -> Vec3f {
  vec4f.scale(mat.x, rhs.x)
  |> vec4f.add(vec4f.scale(mat.y, rhs.y))
  |> vec4f.add(vec4f.scale(mat.z, rhs.z))
  |> vec4f.add(mat.w)
  |> to_xyz()
}

/// Transforms the given 3D vector as a direction.
///
/// This is the equivalent of multiplying the 3D vector as a 4D vector where `w` is
/// `0.0`.
///
/// This method assumes that `mat` contains a valid affine transform.
pub fn transform_vector3(mat: Mat4f, rhs: Vec3f) -> Vec3f {
  vec4f.scale(mat.x, rhs.x)
  |> vec4f.add(vec4f.scale(mat.y, rhs.y))
  |> vec4f.add(vec4f.scale(mat.z, rhs.z))
  |> to_xyz
}

// Private functions

fn quat_to_axes(rotation: Vec4f) -> vec3.Vec3(Vec4f) {
  let Vec4(x:, y:, z:, w:) = vec4f.normalize(rotation)

  let x2 = x +. x
  let y2 = y +. y
  let z2 = z +. z
  let xx = x *. x2
  let xy = x *. y2
  let xz = x *. z2
  let yy = y *. y2
  let yz = y *. z2
  let zz = z *. z2
  let wx = w *. x2
  let wy = y *. y2
  let wz = w *. z2

  let x_axis = Vec4(1.0 -. { yy +. zz }, xy +. wz, xz -. wy, 0.0)
  let y_axis = Vec4(xy -. wz, 1.0 -. { xx +. zz }, yz +. wx, 0.0)
  let z_axis = Vec4(xz +. wy, yz -. wx, 1.0 -. { xx +. yy }, 0.0)
  Vec3(x_axis, y_axis, z_axis)
}

fn quat_from_rotation_axes(
  x_axis: Vec3f,
  y_axis: Vec3f,
  z_axis: Vec3f,
) -> Vec4(Float) {
  // Based on https://github.com/microsoft/DirectXMath `XMQuaternionRotationMatrix`
  let Vec3(x: m00, y: m01, z: m02) = x_axis
  let Vec3(x: m10, y: m11, z: m12) = y_axis
  let Vec3(x: m20, y: m21, z: m22) = z_axis
  case m22 <=. 0.0 {
    True -> {
      // x^2 + y^2 >= z^2 + w^2
      let dif10 = m11 -. m00
      let omm22 = 1.0 -. m22
      case dif10 <=. 0.0 {
        True -> {
          // x^2 >= y^2
          let four_xsq = omm22 -. dif10
          let inv4x = {
            let assert Ok(four_x) = float.square_root(four_xsq)
            0.5 /. four_x
          }
          Vec4(
            four_xsq *. inv4x,
            { m01 +. m10 } *. inv4x,
            { m02 +. m20 } *. inv4x,
            { m12 -. m21 } *. inv4x,
          )
        }
        False -> {
          // y^2 >= x^2
          let four_ysq = omm22 +. dif10
          let inv4y = {
            let assert Ok(four_y) = float.square_root(four_ysq)
            0.5 /. four_y
          }
          Vec4(
            { m01 +. m10 } *. inv4y,
            four_ysq *. inv4y,
            { m12 +. m21 } *. inv4y,
            { m20 -. m02 } *. inv4y,
          )
        }
      }
    }
    False -> {
      // z^2 + w^2 >= x^2 + y^2
      let sum10 = m11 +. m00
      let opm22 = 1.0 +. m22
      case sum10 <=. 0.0 {
        True -> {
          // z^2 >= w^2
          let four_zsq = opm22 -. sum10
          let inv4z = {
            let assert Ok(four_z) = float.square_root(four_zsq)
            0.5 /. four_z
          }
          Vec4(
            { m02 +. m20 } *. inv4z,
            { m12 +. m21 } *. inv4z,
            four_zsq *. inv4z,
            { m01 -. m10 } *. inv4z,
          )
        }
        False -> {
          // w^2 >= z^2
          let four_wsq = opm22 +. sum10
          let inv4w = {
            let assert Ok(four_w) = float.square_root(four_wsq)
            0.5 /. four_w
          }
          Vec4(
            { m12 -. m21 } *. inv4w,
            { m20 -. m02 } *. inv4w,
            { m01 -. m10 } *. inv4w,
            four_wsq *. inv4w,
          )
        }
      }
    }
  }
}
