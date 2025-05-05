//
//  BFloat16+String.swift
//  BFloat16
//
// Simply using the Float impls so that I don't have to implement this monstrosity:
// https://github.com/swiftlang/swift/blob/77eb4f05ec3aeaa78a268aa9d17d32d94de24991/stdlib/public/runtime/SwiftDtoa.cpp#L363

extension BFloat16: CustomStringConvertible {

  /// A textual representation of the value.
  ///
  /// For any finite value, this property provides a string that can be
  /// converted back to an instance of `BFloat16` without rounding errors.  That
  /// is, if `x` is an instance of `BFloat16`, then `BFloat16(x.description) ==
  /// x` is always true.  For any NaN value, the property's value is "nan", and
  /// for positive and negative infinity its value is "inf" and "-inf".
  public var description: String {
    Float(self).description
  }
}

extension BFloat16: CustomDebugStringConvertible {

  /// A textual representation of the value, suitable for debugging.
  ///
  /// This property has the same value as the `description` property, except
  /// that NaN values are printed in an extended format.
  public var debugDescription: String {
    Float(self).debugDescription
  }
}

extension BFloat16: TextOutputStreamable {

  /// Writes a textual representation of this instance into the given output
  /// stream.
  public func write<Target>(to target: inout Target) where Target: TextOutputStream {
    Float(self).write(to: &target)
  }
}

extension BFloat16: LosslessStringConvertible {

  /// Creates a new instance from the given string.
  @inlinable public init?<S: StringProtocol>(_ description: S) {
    guard let float = Float(description) else { return nil }
    self = BFloat16(float)
  }
}
