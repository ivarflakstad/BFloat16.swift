//
//  BFloat16+Hashing.swift
//  BFloat16
//

extension BFloat16: Hashable {
  @inlinable public func hash(into hasher: inout Hasher) {
    // To satisfy the axiom that equality implies hash equality, we need to
    // finesse the hash value of -0.0 to match +0.0.
    let v = isZero ? 0 : self
    hasher.combine(v.bitPattern)
  }
}
