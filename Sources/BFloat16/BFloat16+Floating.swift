//
//  BFloat16.swift
//  BFloat16
//
// Based on swift impls:
// https://github.com/swiftlang/swift/blob/814d2f834fb64319c7952d65cc78ee4707c41a60/stdlib/public/core/FloatingPointTypes.swift.gyb

import Swift
import SwiftShims

#if SWIFT_PACKAGE
  import bfloat16_c
#endif

extension bf16_t {
  /// Swift init to C binding to simplify conversion.
  @_transparent @inlinable @inline(__always)
  init(_ value: BFloat16) {
    self = bf16_from(value._value)
  }
}

extension Float {
  /// BFloat16 to Float via C binding.
  @inlinable @inline(__always)
  public init(_ value: BFloat16) {
    self = to_f32(bf16_t(value))
  }
}

extension BFloat16: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Float

  @_transparent @inlinable @inline(__always)
  public init(floatLiteral value: Float) {
    self = BFloat16(value)
  }
}

extension BFloat16: FloatingPoint {
  public typealias Exponent = Int

  /// Creates a new value from the given sign, exponent, and significand.
  ///
  /// This initializer implements the `scaleB` operation defined by the [IEEE
  /// 754 specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - sign: The sign to use for the new value.
  ///   - exponent: The new value's exponent.
  ///   - significand: The new value's significand.
  @inlinable public init(sign: FloatingPointSign, exponent: Int, significand: BFloat16) {
    var result = significand
    if sign == .minus { result = -result }
    if significand.isFinite && !significand.isZero {
      var clamped = exponent
      let leastNormalExponent = 1 - Int(BFloat16._exponentBias)
      let greatestFiniteExponent = Int(BFloat16._exponentBias)
      if clamped < leastNormalExponent {
        clamped = max(clamped, 3 * leastNormalExponent)
        while clamped < leastNormalExponent {
          result *= BFloat16.leastNormalMagnitude
          clamped -= leastNormalExponent
        }
      } else if clamped > greatestFiniteExponent {
        clamped = min(clamped, 3 * greatestFiniteExponent)
        let step = BFloat16(
          sign: .plus,
          exponentBitPattern: BFloat16._infinityExponent - 1,
          significandBitPattern: 0)
        while clamped > greatestFiniteExponent {
          result *= step
          clamped -= greatestFiniteExponent
        }
      }
      let scale = BFloat16(
        sign: .plus,
        exponentBitPattern: UInt16(Int(BFloat16._exponentBias) + clamped),
        significandBitPattern: 0
      )
      result = result * scale
    }
    self = result
  }

  /// A quiet NaN ("not a number").
  ///
  /// A NaN compares not equal, not greater than, and not less than every
  /// value, including itself. Passing a NaN to an operation generally results
  /// in NaN.
  ///
  ///     let x = 1.21
  ///     // x > BFloat16.nan == false
  ///     // x < BFloat16.nan == false
  ///     // x == BFloat16.nan == false
  ///
  /// Because a NaN always compares not equal to itself, to test whether a
  /// floating-point value is NaN, use its `isNaN` property instead of the
  /// equal-to operator (`==`). In the following example, `y` is NaN.
  ///
  ///     let y = x + BFloat16.nan
  ///     print(y == BFloat16.nan)
  ///     // Prints "false"
  ///     print(y.isNaN)
  ///     // Prints "true"
  @inlinable public static var nan: BFloat16 {
    BFloat16(bf16_nan())
  }

  @inlinable public static var signalingNaN: BFloat16 {
    BFloat16(bitPattern: 0xFF81)
  }

  @inlinable public static var infinity: BFloat16 {
    BFloat16(bitPattern: 0x7F80)
  }

  @inlinable public static var greatestFiniteMagnitude: BFloat16 {
    BFloat16(bitPattern: 0x7F7F)
  }

  @inlinable public static var pi: BFloat16 {
    BFloat16(bitPattern: 0x4049)
  }

  @inlinable public var ulp: BFloat16 {
    guard _fastPath(isFinite) else { return .nan }
    if _fastPath(isNormal) {
      let bitPattern_ = bitPattern & BFloat16.infinity.bitPattern
      return BFloat16(bitPattern: bitPattern_) * BFloat16.ulpOfOne
    }
    // On arm, flush subnormal values to 0.
    return .leastNormalMagnitude * BFloat16.ulpOfOne
  }

  @inlinable public static var ulpOfOne: BFloat16 {
    return 0x1.0p-8
  }

  @inlinable public static var leastNormalMagnitude: BFloat16 {
    0x1.0p-14
  }

  @inlinable public static var leastNonzeroMagnitude: BFloat16 {
    leastNormalMagnitude * ulpOfOne
  }

  @inlinable public var sign: FloatingPointSign {
    return FloatingPointSign(
      rawValue: Int(bitPattern &>> (BFloat16.significandBitCount + BFloat16.exponentBitCount)))!
  }

  @inlinable
  @_semantics("optimize.sil.inline.constant.arguments")
  public var exponent: Int {
    if !isFinite { return .max }
    if isZero { return .min }
    let provisional = Int(exponentBitPattern) - Int(BFloat16._exponentBias)
    if isNormal { return provisional }
    let shift =
      BFloat16.significandBitCount - significandBitPattern._binaryLogarithm()
    return provisional + 1 - shift
  }

  public var significand: BFloat16 {
    if isNaN { return self }
    if isNormal {
      return BFloat16(
        sign: .plus,
        exponentBitPattern: BFloat16._exponentBias,
        significandBitPattern: significandBitPattern)
    }
    if _slowPath(isSubnormal) {
      let shift =
        BFloat16.significandBitCount - significandBitPattern._binaryLogarithm()
      return BFloat16(
        sign: .plus,
        exponentBitPattern: BFloat16._exponentBias,
        significandBitPattern: significandBitPattern &<< shift
      )
    }
    // zero or infinity.
    return BFloat16(
      sign: .plus,
      exponentBitPattern: exponentBitPattern,
      significandBitPattern: 0
    )
  }

  public static func / (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_div(bf16_t(lhs), bf16_t(rhs)))
  }

  public static func /= (lhs: inout BFloat16, rhs: BFloat16) {
    lhs = lhs / rhs
  }

  @inlinable @inline(__always) public mutating func formRemainder(dividingBy other: BFloat16) {
    var lhs = Float(self)
    lhs.formRemainder(dividingBy: Float(other))
    self = BFloat16(lhs)
  }

  @inlinable @inline(__always) public mutating func formTruncatingRemainder(
    dividingBy other: BFloat16
  ) {
    var f = Float(self)
    f.formTruncatingRemainder(dividingBy: Float(other))
    self = BFloat16(f)
  }

  @_transparent public mutating func formSquareRoot() {
    self = BFloat16(bf16_sqrt(bf16_t(self)))
  }

  public mutating func addProduct(_ lhs: BFloat16, _ rhs: BFloat16) {
    self = BFloat16(bf16_fma(bf16_t(lhs), bf16_t(rhs), bf16_t(self)))
  }

  public mutating func round(_ rule: FloatingPointRoundingRule) {
    var f = Float(self)
    f.round(rule)
    self = BFloat16(f)
  }

  @inlinable public var nextUp: BFloat16 {
    // Silence signaling NaNs, map -0 to +0.
    let x = self + 0
    if _fastPath(x < .infinity) {
      let increment = Int16(bitPattern: x.bitPattern) &>> 15 | 1
      let bitPattern_ = x.bitPattern &+ UInt16(bitPattern: increment)
      return BFloat16(bitPattern: bitPattern_)
    }
    return x
  }

  public func isEqual(to other: BFloat16) -> Bool {
    equal(bf16_t(self), bf16_t(other))
  }

  public func isLess(than other: BFloat16) -> Bool {
    lt(bf16_t(self), bf16_t(other))
  }

  public func isLessThanOrEqualTo(_ other: BFloat16) -> Bool {
    lte(bf16_t(self), bf16_t(other))
  }

  @inlinable public var isNormal: Bool {
    exponentBitPattern > 0 && isFinite
  }

  @inlinable public var isFinite: Bool {
    exponentBitPattern < BFloat16._infinityExponent
  }

  @inlinable public var isZero: Bool {
    exponentBitPattern == 0 && significandBitPattern == 0
  }
  @inlinable public var isSubnormal: Bool {
    exponentBitPattern == 0 && significandBitPattern != 0
  }
  @inlinable public var isInfinite: Bool {
    bitPattern & 0x7FFF == 0x7F80
  }
  @inlinable public var isNaN: Bool {
    bitPattern & 0x7FFF > 0x7F80
  }

  @inlinable public var isSignalingNaN: Bool {
    isNaN && (significandBitPattern & BFloat16._quietNaNMask) == 0
  }

  @inlinable public var isCanonical: Swift.Bool {
    // All Float and Double encodings are canonical in IEEE 754.
    //
    // On platforms that do not support subnormals, we treat them as
    // non-canonical encodings of zero.
    if BFloat16.leastNonzeroMagnitude == BFloat16.leastNormalMagnitude {
      if exponentBitPattern == 0 && significandBitPattern != 0 {
        return false
      }
    }
    return true
  }
}

extension BFloat16: BinaryFloatingPoint {
  /// A type that represents the encoded significand of a value.
  public typealias RawSignificand = UInt16
  /// A type that represents the encoded exponent of a value.
  public typealias RawExponent = UInt16

  /// Creates a new instance from the specified sign and bit patterns.
  ///
  /// The values passed as `exponentBitPattern` and `significandBitPattern` are
  /// interpreted in the binary interchange format defined by the [IEEE 754
  /// specification][spec].
  ///
  /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
  ///
  /// - Parameters:
  ///   - sign: The sign of the new value.
  ///   - exponentBitPattern: The bit pattern to use for the exponent field of
  ///     the new value.
  ///   - significandBitPattern: The bit pattern to use for the significand
  ///     field of the new value.
  @inlinable @inline(__always)
  public init(
    sign: FloatingPointSign,
    exponentBitPattern: UInt16,
    significandBitPattern: UInt16
  ) {
    let signShift = BFloat16.significandBitCount + BFloat16.exponentBitCount
    let sign = UInt16(sign == .minus ? 1 : 0)
    let exponent = UInt16(
      exponentBitPattern & BFloat16._infinityExponent
    )
    let significand = UInt16(
      significandBitPattern & BFloat16._significandMask
    )
    self.init(
      bitPattern:
        sign &<< signShift
        | exponent &<< UInt16(BFloat16.significandBitCount)
        | significand
    )
  }

  /// Creates a new instance from the given value, rounded to the closest
  /// possible representation.
  ///
  /// - Parameter value: A floating-point value to be converted.
  @inlinable @inline(__always)
  public init(_ value: Float) {
    self = BFloat16(bf16_from(value))
  }

  /// Creates a new instance from the given value, rounded to the closest
  /// possible representation.
  ///
  /// - Parameter value: A floating-point value to be converted.
  @inlinable @inline(__always)
  public init(_ value: Double) {
    self = BFloat16(bf16_from(value))
  }

  @inlinable public static var exponentBitCount: Int {
    8
  }

  @inlinable public static var significandBitCount: Int {
    7
  }

  @inlinable internal static var _infinityExponent: UInt16 {
    1 &<< (UInt(exponentBitCount) - 1)
  }

  @inlinable internal static var _exponentBias: UInt16 {
    _infinityExponent &>> 1
  }

  @inlinable internal static var _significandMask: UInt16 {
    1 &<< UInt16(significandBitCount) - 1
  }

  @inlinable internal static var _quietNaNMask: UInt16 {
    1 &<< UInt16(significandBitCount - 1)
  }

  @inlinable public var bitPattern: UInt16 {
    _value
  }

  /// The raw encoding of the value's exponent field.
  ///
  /// This value is unadjusted by the type's exponent bias.
  @inlinable public var exponentBitPattern: UInt16 {
    UInt16(
      bitPattern &>> UInt16(BFloat16.significandBitCount)
    ) & BFloat16._infinityExponent
  }

  @inlinable public var significandBitPattern: UInt16 {
    bitPattern & BFloat16._significandMask
  }

  @inlinable public var binade: BFloat16 {
    guard _fastPath(isFinite) else { return .nan }
    if _slowPath(isSubnormal) {
      let bitPattern_ = (self * 0x1p10).bitPattern & (-BFloat16.infinity).bitPattern
      return BFloat16(bitPattern: bitPattern_) * 0x1p-10
    }
    return BFloat16(bitPattern: bitPattern & (-BFloat16.infinity).bitPattern)
  }

  @inlinable
  @_semantics("optimize.sil.inline.constant.arguments")
  public var significandWidth: Int {
    let trailingZeroBits = significandBitPattern.trailingZeroBitCount
    if isNormal {
      guard significandBitPattern != 0 else { return 0 }
      return BFloat16.significandBitCount &- trailingZeroBits
    }
    if isSubnormal {
      let leadingZeroBits = significandBitPattern.leadingZeroBitCount
      return UInt16.bitWidth &- (trailingZeroBits &+ leadingZeroBits &+ 1)
    }
    return -1
  }
}
