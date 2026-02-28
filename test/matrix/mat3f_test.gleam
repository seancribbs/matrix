import matrix/mat3f

pub fn mat3_inverse_test() {
  // Example from wolfram alpha
  let m = mat3f.new(4.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0)
  let inverse =
    mat3f.new(
      1.0 /. 3.0,
      -0.5,
      1.0 /. 6.0,
      0.0,
      0.5,
      -0.5,
      -1.0 /. 3.0,
      1.0,
      1.0 /. 3.0,
    )
  let assert Ok(result) = mat3f.inverse(m)
  assert result == inverse
}
