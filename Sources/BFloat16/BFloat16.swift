//
//  BFloat.swift
//  BFloat
//
//  Created by Ivar Flakstad on 22/02/2024.
//

import Swift
import SwiftShims

#if SWIFT_PACKAGE
import bfloat16_c
#endif


@frozen
public struct BFloat16 {
  @usableFromInline @inline(__always)
  internal var _value: bf16_t;
  
  @_transparent
  public init() {
    _value = bf16_zero()
  }
  
  @_transparent @inlinable @inline(__always)
  init(_ value: bf16_t) {
    _value = value
  }
  
  @_transparent @inlinable @inline(__always)
  init(bitPattern: UInt16) {
    _value = bitPattern
  }
  
  @usableFromInline @inline(__always)
  func float() -> Float {
    return to_f32(self._value);
  }
  
  @inlinable public static var one: BFloat16 {
    BFloat16(bitPattern: 0x3F80)
  }
  
  @inlinable public static var zero: BFloat16 {
    BFloat16(bf16_zero())
  }
  
  @inlinable public static var neg_one: BFloat16 {
    BFloat16(bitPattern: 0xBF80)
  }
  
  @inlinable public static var neg_zero: BFloat16 {
    BFloat16(bitPattern: 0x8000)
  }
  
  @inlinable public static var epsilon: BFloat16 {
    BFloat16(bitPattern: 0x3C00)
  }
}

extension bf16_t {
  @_transparent @inlinable @inline(__always)
  init(_ value: BFloat16) {
    self = value._value
  }
}

extension BFloat16: CustomStringConvertible {
  /// A textual representation of the value.
  ///
  /// For any finite value, this property provides a string that can be
  /// converted back to an instance of `BFloat16` without rounding errors.  That
  /// is, if `x` is an instance of `BFloat16`, then `BFloat16(x.description) ==
  /// x` is always true.  For any NaN value, the property's value is "nan", and
  /// for positive and negative infinity its value is "inf" and "-inf".
  public var description: String {
    if isNaN {
      return "nan"
    }
    return float().description
  }
}


extension BFloat16: CustomDebugStringConvertible {
  /// A textual representation of the value, suitable for debugging.
  ///
  /// This property has the same value as the `description` property, except
  /// that NaN values are printed in an extended format.
  public var debugDescription: String {
    if isNaN {
      return "nan"
    }
    return float().debugDescription
  }
}

extension BFloat16: TextOutputStreamable {
  public func write<Target>(to target: inout Target) where Target: TextOutputStream {
    float().write(to: &target)
  }
}

extension BFloat16: AdditiveArithmetic {
  public static func + (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_add(bf16_t(lhs), bf16_t(rhs)))
  }
  
  
  public static func - (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_sub(bf16_t(lhs), bf16_t(rhs)))
  }
}

extension BFloat16: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: UInt16) {
    self = BFloat16(Float(value))
  }
}

extension BFloat16: ExpressibleByFloatLiteral {
  public typealias FloatLiteralType = Float
  
  @_transparent @inlinable @inline(__always)
  public init(floatLiteral value: Float) {
    self = BFloat16(value)
  }
}



extension BFloat16: Numeric {
  public init?<T>(exactly source: T) where T : BinaryInteger {
    self = BFloat16(source)
  }
  
  public var magnitude: BFloat16 {
    BFloat16(sign: .plus, exponent: self.exponent, significand: self.significand)
  }
  
  public static func * (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_mul(bf16_t(lhs), bf16_t(rhs)))
  }
  
  public static func *= (lhs: inout BFloat16, rhs: BFloat16) {
    lhs = lhs * rhs
  }
}

extension BFloat16: SignedNumeric {
  prefix public static func - (operand: BFloat16) -> BFloat16 {
    BFloat16(bf16_neg(bf16_t(operand)))
  }
 
  mutating public func negate() {
    self = -self
  }
}

extension BFloat16: BinaryFloatingPoint {
  public typealias Magnitude = BFloat16
  public typealias Exponent = Int
  public typealias RawSignificand = UInt16
  
  
  @inlinable public static var exponentBitCount: Int {
    get {
      return 8
    }
  }
  @inlinable public static var significandBitCount: Int {
    get {
      return 7
    }
  }
  @inlinable internal static var _infinityExponent: UInt {
    @inline(__always) get { return 1 &<< (UInt(exponentBitCount) - 1) }
  }
  
  @inlinable internal static var _exponentBias: UInt {
    @inline(__always) get { return _infinityExponent &>> 1 }
  }
  
  @inlinable internal static var _significandMask: UInt16 {
    @inline(__always) get {
      return 1 &<< UInt16(significandBitCount) - 1
    }
  }
  
  @inlinable internal static var _quietNaNMask: UInt16 {
    @inline(__always) get {
      return 1 &<< UInt16(significandBitCount - 1)
    }
  }
  
  @inlinable public var bitPattern: UInt16 {
    @inline(__always) get {
      return _value
    }
  }
  
  @inlinable public var sign: FloatingPointSign {
    @inline(__always) get {
      return FloatingPointSign(rawValue: Int(bitPattern &>> (BFloat16.significandBitCount + BFloat16.exponentBitCount)))!
    }
  }
  @inlinable public var exponentBitPattern: UInt {
    get {
      return UInt(bitPattern &>> UInt16(BFloat16.significandBitCount)) & BFloat16._infinityExponent
    }
  }
  @inlinable public var significandBitPattern: UInt16 {
    get {
      return bitPattern & BFloat16._significandMask
    }
  }
  
  @inlinable @inline(__always)
  public init(_ value: Float) {
    self = BFloat16(bf16_from(value));
  }
  
  
  @inlinable @inline(__always)
  public init(sign: FloatingPointSign, exponentBitPattern: UInt, significandBitPattern: UInt16) {
    let signShift = BFloat16.significandBitCount + BFloat16.exponentBitCount
    let sign = UInt16(sign == .minus ? 1 : 0)
    let exponent = UInt16(
      exponentBitPattern & BFloat16._infinityExponent
    )
    let significand = UInt16(
      significandBitPattern & BFloat16._significandMask
    )
    self.init(bitPattern:
                sign &<< UInt16(signShift) |
              exponent &<< UInt16(BFloat16.significandBitCount) |
              significand
    )
  }
  
  @inlinable public var isCanonical: Swift.Bool {
    get {
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
  
  @inlinable public var binade: BFloat16 {
    get {
      guard _fastPath(isFinite) else { return .nan }
      if _slowPath(isSubnormal) {
        let bitPattern_ = (self * 0x1p10).bitPattern & (-BFloat16.infinity).bitPattern
        return BFloat16(bitPattern: bitPattern_) * 0x1p-10
      }
      return BFloat16(bitPattern: bitPattern & (-BFloat16.infinity).bitPattern)
    }
  }
  
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
    get {
      guard _fastPath(isFinite) else { return .nan }
      if _fastPath(isNormal) {
        let bitPattern_ = bitPattern & BFloat16.infinity.bitPattern
        return BFloat16(bitPattern: bitPattern_) * BFloat16.ulpOfOne
      }
      // On arm, flush subnormal values to 0.
      return .leastNormalMagnitude * BFloat16.ulpOfOne
    }
  }
  
  @inlinable public static var leastNormalMagnitude: BFloat16 {
    0x1.0p-14
  }
  
  @inlinable public static var leastNonzeroMagnitude: BFloat16 {
    return leastNormalMagnitude * ulpOfOne
  }
  
  @inlinable public static var ulpOfOne: BFloat16 {
    get {
      return 0x1.0p-8
    }
  }
  
  @inlinable public var exponent: Int {
    get {
      if !isFinite { return .max }
      if isZero { return .min }
      let provisional = Int(exponentBitPattern) - Int(BFloat16._exponentBias)
      if isNormal { return provisional }
      let shift =
      BFloat16.significandBitCount - significandBitPattern._binaryLogarithm()
      return provisional + 1 - shift
    }
  }
  
  public var significand: BFloat16 {
    get {
      if isNaN { return self }
      if isNormal {
        return BFloat16(sign: .plus,
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
  }
  
  @inlinable public init(sign: FloatingPointSign, exponent: Int, significand: BFloat16) {
    var result = significand
    if sign == .minus { result = -result }
    if significand.isFinite && !significand.isZero {
      var clamped = exponent
      let leastNormalExponent = 1 - Int(BFloat16._exponentBias)
      let greatestFiniteExponent = Int(BFloat16._exponentBias)
      if clamped < leastNormalExponent {
        clamped = max(clamped, 3*leastNormalExponent)
        while clamped < leastNormalExponent {
          result  *= BFloat16.leastNormalMagnitude
          clamped -= leastNormalExponent
        }
      }
      else if clamped > greatestFiniteExponent {
        clamped = min(clamped, 3*greatestFiniteExponent)
        let step = BFloat16(sign: .plus,
                            exponentBitPattern: BFloat16._infinityExponent - 1,
                            significandBitPattern: 0)
        while clamped > greatestFiniteExponent {
          result  *= step
          clamped -= greatestFiniteExponent
        }
      }
      let scale = BFloat16(
        sign: .plus,
        exponentBitPattern: UInt(Int(BFloat16._exponentBias) + clamped),
        significandBitPattern: 0
      )
      result = result * scale
    }
    self = result
  }
  
  @inlinable public var significandWidth: Int {
    get {
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
  
  @inlinable public var nextUp: BFloat16 {
    get {
      // Silence signaling NaNs, map -0 to +0.
      let x = self + 0
      if _fastPath(x < .infinity) {
        let increment = Int16(bitPattern: x.bitPattern) &>> 15 | 1
        let bitPattern_ = x.bitPattern &+ UInt16(bitPattern: increment)
        return BFloat16(bitPattern: bitPattern_)
      }
      return x
    }
  }
  
  public mutating func round(_ rule: FloatingPointRoundingRule) {
    var f = Float(self)
    f.round(rule)
    self = BFloat16(f)
  }
  
  public static func / (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_div(bf16_t(lhs), bf16_t(rhs)))
  }
  
  public static func /= (lhs: inout BFloat16, rhs: BFloat16) {
    lhs = lhs / rhs
  }
  
  @inlinable @inline(__always) public mutating func formRemainder(dividingBy other: BFloat16) {
    self = BFloat16(_stdlib_remainderf(Float(self), Float(other)))
  }
  
  @inlinable @inline(__always) public mutating func formTruncatingRemainder(dividingBy other: BFloat16) {
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
    @inline(__always) get {
      return exponentBitPattern > 0 && isFinite
    }
  }
  
  @inlinable public var isFinite: Bool {
    @inline(__always) get {
      return exponentBitPattern < BFloat16._infinityExponent
    }
  }
  
  @inlinable public var isZero: Bool {
    @inline(__always) get {
      return exponentBitPattern == 0 && significandBitPattern == 0
    }
  }
  @inlinable public var isSubnormal: Bool {
    @inline(__always) get {
      return exponentBitPattern == 0 && significandBitPattern != 0
    }
  }
  @inlinable public var isInfinite: Bool {
    @inline(__always) get {
      return bitPattern & 0x7FFF == 0x7F80
    }
  }
  @inlinable public var isNaN: Bool {
    @inline(__always) get {
      return bitPattern & 0x7FFF > 0x7F80
    }
  }
  
  @inlinable public var isSignalingNaN: Bool {
    @inline(__always) get {
      return isNaN && (significandBitPattern & BFloat16._quietNaNMask) == 0
    }
  }
}

extension BFloat16: Strideable {
  public typealias Stride = BFloat16
  
  @_transparent
  public func distance(to other: Self) -> Self.Stride {
    return other - self
  }
  
  @_transparent
  public func advanced(by n: Self.Stride) -> Self {
    self + n
  }
}

extension BFloat16: Hashable {
  @inlinable public func hash(into hasher: inout Hasher) {
    // To satisfy the axiom that equality implies hash equality, we need to
    // finesse the hash value of -0.0 to match +0.0.
    let v = isZero ? 0 : self
    hasher.combine(v.bitPattern)
  }
}

extension BFloat16: Codable {
  
  /**
   Creates a new instance by decoding from the given decoder.
   
   The way in which `BFloat` decodes itself is by first decoding the next largest
   floating-point type that conforms to `Decodable` and then attempting to cast it
   down to `BFloat`. This initializer throws an error if reading from the decoder
   fails, if the data read is corrupted or otherwise invalid, or if the decoded
   floating-point value is too large to fit in a `BFloat` type.
   
   - Parameters:
   - decoder: The decoder to read data from.
   */
  @_transparent
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let float = try container.decode(Float.self)
    
    guard float.isInfinite || float.isNaN || abs(float) <= BFloat16.greatestFiniteMagnitude.float() else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Parsed number \(float) does not fit in \(type(of: self))."))
    }
    
    self.init(float)
  }
  
  /**
   Encodes this value into the given encoder.
   
   The way in which `BFloat` encodes itself is by first prompting itself to the next
   largest floating-point type that conforms to `Encodable` and encoding that value
   to the encoder. This function throws an error if any values are invalid for the
   given encoder’s format.
   
   - Parameters:
   - encoder: The encoder to write data to.
   
   - Note: This documentation comment was copied from `Double`.
   */
  @_transparent
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(float())
  }
}


extension BFloat16 : SIMDScalar {
  
  public typealias SIMDMaskScalar = Int16
  
  /// Storage for a vector of two brain floating-point values.
  @frozen @_alignment(4) public struct SIMD2Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD2Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD2Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD2Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
  
  /// Storage for a vector of four brain floating-point values.
  @frozen @_alignment(8) public struct SIMD4Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD4Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD4Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD4Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
  
  /// Storage for a vector of four brain floating-point values.
  @frozen @_alignment(16) public struct SIMD8Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD8Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD8Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD8Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
  
  /// Storage for a vector of four brain floating-point values.
  @frozen @_alignment(16) public struct SIMD16Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD16Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD16Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD16Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
  
  /// Storage for a vector of four brain floating-point values.
  @frozen @_alignment(16) public struct SIMD32Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD32Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD32Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD32Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
  
  /// Storage for a vector of four brain floating-point values.
  @frozen @_alignment(16) public struct SIMD64Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD64Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        return _value.scalarCount
      }
    }
    
    /// Creates a vector with zero in all lanes.
    @_transparent public init() {
      _value = UInt16.SIMD64Storage.init();
    }
    @_alwaysEmitIntoClient internal init(_ _builtin: UInt16.SIMD64Storage) {
      _value = _builtin
    }
    
    /// Accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to access. `index` must be in
    ///   the range `0..<scalarCount`.
    public subscript(index: Int) -> BFloat16 {
      @_transparent get {
        BFloat16(bitPattern: _value[index])
      }
      @_transparent set {
        _value[index] = newValue._value
      }
    }
    /// The type of scalars in the vector space.
    public typealias Scalar = BFloat16
  }
}
