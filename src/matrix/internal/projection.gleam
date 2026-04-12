import vec/vec2.{type Vec2, Vec2}
import vec/vec3.{type Vec3, Vec3}
import vec/vec4.{type Vec4, Vec4}

pub fn to_xz(v: Vec3(a)) -> Vec2(a) {
  Vec2(x: v.x, y: v.z)
}

pub fn to_xy(v: Vec3(a)) -> Vec2(a) {
  Vec2(x: v.x, y: v.y)
}

pub fn to_yz(v: Vec3(a)) -> Vec2(a) {
  Vec2(x: v.y, y: v.z)
}

pub fn to_xyz(vec: Vec4(a)) -> Vec3(a) {
  Vec3(x: vec.x, y: vec.y, z: vec.z)
}

pub fn extend2(vec: Vec2(a), z: a) -> Vec3(a) {
  Vec3(x: vec.x, y: vec.y, z:)
}

pub fn extend3(vec: Vec3(a), w: a) -> Vec4(a) {
  Vec4(x: vec.x, y: vec.y, z: vec.z, w:)
}
