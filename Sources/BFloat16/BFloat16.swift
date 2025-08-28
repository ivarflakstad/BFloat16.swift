//
//  BFloat16.swift
//  BFloat16
//

import Swift
import SwiftShims

#if SWIFT_PACKAGE
  import bfloat16_c
#endif

/// A Brain floating-point value type.
///
/// This is a shortened version of `Float`'s 32-bit type. It has the same amount of exponent bits,
/// but shortens the significand precision from 24 bits to 8 bits.
@frozen
public struct BFloat16 {
  @usableFromInline @inline(__always)
  internal var _value: bf16_t

  /// Create a `BFloat16` with a value of zero.
  @_transparent @inlinable @inline(__always)
  public init() {
    _value = 0
  }

  @_transparent @inlinable @inline(__always)
  init(_ value: bf16_t) {
    _value = value
  }

  /// Create a `BFloat16` from a 16-bit pattern.
  @_transparent @inlinable @inline(__always)
  public init(bitPattern: UInt16) {
    _value = bf16_from(bitPattern)
  }

  /// The zero value.
  @inlinable public static var zero: BFloat16 {
    BFloat16()
  }

  /// A value equal to zero with a negative sign.
  @inlinable public static var negativeZero: BFloat16 {
    BFloat16(bitPattern: 0x8000)
  }

  /// A value equal to `1`.
  @inlinable public static var one: BFloat16 {
    BFloat16(bitPattern: 0x3F80)
  }

  /// A value equal to `-1`.
  @inlinable public static var negativeOne: BFloat16 {
    BFloat16(bitPattern: 0xBF80)
  }
}

extension BFloat16: Sendable {}

extension BFloat16: Strideable {
  public typealias Stride = BFloat16

  @_transparent
  public func distance(to other: Self) -> Self.Stride {
    other - self
  }

  @_transparent
  public func advanced(by n: Self.Stride) -> Self {
    self + n
  }
}
