// //// 3x3 matrices of floats

// import gleam/float
// import gleam/result
// import gleam_community/maths
// import vec/vec3.{type Vec3, Vec3}
// import vec/vec3f.{type Vec3f}
// import vec/vec4
// import vec/vec4f

// /// Mat3f is a 3x3 column-major matrix of `Float`s.
// pub type Mat3f =
//   Vec3(Vec3f)

// /// A Mat3f with all elements set to `0.0`
// pub const zero: Mat3f = vec3.Vec3(vec3f.zero, vec3f.zero, vec3f.zero)

// const x: Vec3f = Vec3(1.0, 0.0, 0.0)

// const y: Vec3f = Vec3(0.0, 1.0, 0.0)

// const z: Vec3f = Vec3(0.0, 0.0, 1.0)

// /// A Mat3f representing the identity, i.e. `1.0` is on the diagonal.
// pub const identity: Mat3f = vec3.Vec3(x, y, z)

// /// Constructs a `Mat3f` from its components:
// /// ```text
// /// | a  d  g |
// /// | b  e  h |
// /// | c  f  i |
// /// ```
// pub fn new(
//   a: Float,
//   b: Float,
//   c: Float,
//   d: Float,
//   e: Float,
//   f: Float,
//   g: Float,
//   h: Float,
//   i: Float,
// ) -> Mat3f {
//   Vec3(Vec3(a, b, c), Vec3(d, e, f), Vec3(g, h, i))
// }

// /// Constructs a `Mat3f` from its three columns.
// /// ```text
// /// | ax  bx  cx |
// /// | ay  by  cy |
// /// | az  bz  cz |
// /// ```
// pub fn from_cols(a: Vec3f, b: Vec3f, c: Vec3f) -> Mat3f {
//   Vec3(a, b, c)
// }

// /// Constructs a `Mat3f` with the given diagonal and all other entries set to 0.
// /// ```text
// /// | x    0.0  0.0 |
// /// | 0.0  y    0.0 |
// /// | 0.0  0.0  z   |
// /// ```
// pub fn from_diagonal(diag: Vec3f) -> Mat3f {
//   new(diag.x, 0.0, 0.0, 0.0, diag.y, 0.0, 0.0, 0.0, diag.z)
// }

// /// Constructs a 3D rotation matrix from the given quaternion, represented as a `vec4.Vec4(Float)`.
// pub fn from_quaternion(q: vec4f.Vec4f) -> Mat3f {
//   let rotation = vec4f.normalize(q)

//   let x2 = rotation.x +. rotation.x
//   let y2 = rotation.y +. rotation.y
//   let z2 = rotation.z +. rotation.z
//   let xx = rotation.x *. x2
//   let xy = rotation.x *. y2
//   let xz = rotation.x *. z2
//   let yy = rotation.y *. y2
//   let yz = rotation.y *. z2
//   let zz = rotation.z *. z2
//   let wx = rotation.w *. x2
//   let wy = rotation.w *. y2
//   let wz = rotation.w *. z2

//   from_cols(
//     Vec3(1.0 -. { yy +. zz }, xy +. wz, xz -. wy),
//     Vec3(xy -. wz, 1.0 -. { xx +. zz }, yz +. wx),
//     Vec3(xz +. wy, yz -. wx, 1.0 -. { xx +. yy }),
//   )
// }

// /// Transposes the `Mat3f` along the diagonal.
// pub fn transpose(mat: Mat3f) -> Mat3f {
//   new(
//     mat.x.x,
//     mat.y.x,
//     mat.z.x,
//     mat.x.y,
//     mat.y.y,
//     mat.z.y,
//     mat.x.z,
//     mat.y.z,
//     mat.z.z,
//   )
// }

// /// Returns the determinant for the `Mat3f`.
// pub fn determinant(mat: Mat3f) -> Float {
//   mat.x.x *. mat.y.y -. mat.x.y *. mat.y.x
// }

// /// Inverts the `Mat3f`, returning an error if the determinant is zero.
// pub fn inverse(mat: Mat3f) -> Result(Mat3f, Nil) {
//   use inv_det <- result.map(float.divide(1.0, determinant(mat)))
//   new(
//     mat.y.y *. inv_det,
//     mat.x.y *. inv_det *. -1.0,
//     mat.y.x *. inv_det *. -1.0,
//     mat.x.x *. inv_det,
//   )
// }

// /// Transforms a `Vec3f` by this `Mat3f`.
// pub fn mul_vec3(mat: Mat3f, rhs: Vec3f) -> Vec3f {
//   Vec3(
//     mat.x.x *. rhs.x +. mat.y.x *. rhs.y,
//     mat.x.y *. rhs.x +. mat.y.y *. rhs.y,
//   )
// }

// /// Transforms a `Vec3f` by the transpose of this `Mat3f`.
// pub fn mul_transpose_vec3(mat: Mat3f, rhs: Vec3f) -> Vec3f {
//   Vec3(vec3f.dot(mat.x, rhs), vec3f.dot(mat.y, rhs))
// }

// /// Negates all elements of the `Mat3f`
// pub fn negate(mat: Mat3f) -> Mat3f {
//   from_cols(vec3f.negate(mat.x), vec3f.negate(mat.y))
// }

// /// Adds two `Mat3f` together.
// pub fn add(a: Mat3f, b: Mat3f) -> Mat3f {
//   from_cols(vec3f.add(a.x, b.x), vec3f.add(a.y, b.y))
// }

// /// Subtracts one `Mat3f` from the other.
// pub fn subtract(a: Mat3f, b: Mat3f) -> Mat3f {
//   from_cols(vec3f.subtract(a.x, b.x), vec3f.subtract(a.y, b.y))
// }

// /// Multiplies two `Mat3f` together.
// pub fn multiply(a: Mat3f, b: Mat3f) -> Mat3f {
//   from_cols(mul_vec3(a, b.x), mul_vec3(a, b.y))
// }

// /// Divides one `Mat3f` by another. Equivalent to multiplying the inverse of the second matrix.
// pub fn divide(a: Mat3f, b: Mat3f) -> Result(Mat3f, Nil) {
//   use inv_b <- result.map(inverse(b))
//   multiply(a, inv_b)
// }

// /// Scales the `Mat3f` by a `Float` factor.
// pub fn scale(mat: Mat3f, scale: Float) -> Mat3f {
//   from_cols(vec3f.scale(mat.x, scale), vec3f.scale(mat.y, scale))
// }

// /// Scales the `Mat3f` by a `Vec3f`.
// ///
// /// This is faster than creating a diagonal scaling matrix and then multiplying that.
// pub fn scale_diagonal(mat: Mat3f, scale: Vec3f) -> Mat3f {
//   from_cols(vec3f.scale(mat.x, scale.x), vec3f.scale(mat.y, scale.y))
// }
