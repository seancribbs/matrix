# matrix_gleam

Matrix mathematics for Gleam, inspired by portions of the Rust `glam` library.

Matrices in this library are compositions of vectors from the `vec` library (as type aliases), so many of their operations are expressed in terms of operations on `vec` types. You can build your own on top in the same way!

All contained matrices are column-major; that is, in a 2x2 matrix, the first _column_ is the `x` component of the `Vec2`.

[![Package Version](https://img.shields.io/hexpm/v/matrix_gleam)](https://hex.pm/packages/matrix_gleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/matrix_gleam/)

```sh
gleam add matrix_gleam
```
```gleam
import matrix/mat3f
import vec/vec3
import vec/vec3f

pub fn main() -> Nil {
  let v = vec3.Vec3(2.2, 3.5, -0.4)
  assert v == mat3f.identity |> mat3f.mul_vec3(v)
}
```

Further documentation can be found at <https://hexdocs.pm/matrix_gleam>.

## Development

```sh
gleam test  # Run the tests
```
