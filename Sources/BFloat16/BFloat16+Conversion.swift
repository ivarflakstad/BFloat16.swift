//
//  BFloat16+Conversion.swift
//  BFloat16
//

extension BinaryInteger {
  /// Creates an integer from the given `BFloat16`, rounding toward
  /// zero.
  ///
  /// Any fractional part of the value passed as `source` is removed, rounding
  /// the value toward zero.
  ///
  ///     let x = Int(21.5 as BFloat16)
  ///     // x == 21
  ///     let y = Int(-21.5 as BFloat16)
  ///     // y == -21
  ///
  /// If `source` is outside the bounds of this type after rounding toward
  /// zero, a runtime error may occur.
  ///
  ///     let z = UInt(-21.5 as BFloat16)
  ///     // Error: ...the result would be less than UInt.min
  ///
  /// - Parameter source: A `BFloat16` value to convert to an integer.
  ///   `source` must be representable in this type after rounding toward
  ///   zero.
  init(_ source: BFloat16) {
    self = Self(Float(source))
  }
  
  /// Creates an integer from the given `BFloat16`, if it can be
  /// represented exactly.
  ///
  /// If the value passed as `source` is not representable exactly, the result
  /// is `nil`. In the following example, the constant `x` is successfully
  /// created from a value of `21.0`, while the attempt to initialize the
  /// constant `y` from `21.5` fails:
  ///
  ///     let x = Int(exactly: 21.0 as BFloat16)
  ///     // x == Optional(21)
  ///     let y = Int(exactly: 21.5 as BFloat16)
  ///     // y == nil
  ///
  /// - Parameter source: A `BFloat16` to convert to an integer.
  init?(exactly source: BFloat16) {
    guard let value = Self(exactly: Float(source)) else {
      return nil
    }
    
    self = value
  }
}

extension BFloat16 {
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// If `other` can't be represented as an instance of `BFloat16` without
  /// rounding, the result of this initializer is `nil`. In particular,
  /// passing NaN as `other` always results in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: Float) {
    self = BFloat16(other)
    guard Float(self) == other else { return nil }
  }
  
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// If `other` can't be represented as an instance of `BFloat16` without
  /// rounding, the result of this initializer is `nil`. In particular,
  /// passing NaN as `other` always results in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: Double) {
    self = BFloat16(other)
    guard Double(self) == other else { return nil }
  }
}

extension Float {
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// The `Float` type can represent any `BFloat16` value without losing
  /// precision, but passing NaN as `other` will result in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: BFloat16) {
    guard !other.isNaN else { return nil }
    self = Float(other)
  }
}

extension Double {
  /// Creates a new instance that approximates the given value.
  /// - Parameter other: The value to use for the new instance.
  public init(_ other: BFloat16) {
    self.init(Float(other))
  }
  
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// If `other` can't be represented as an instance of `Double` without
  /// rounding, the result of this initializer is `nil`. In particular,
  /// passing NaN as `other` always results in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: BFloat16) {
    self = Double(other)
    guard BFloat16(self) == other else { return nil }
  }
}

#if canImport(Foundation)
import Foundation

extension BFloat16 {
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// If `other` can't be represented as an instance of `BFloat16` without
  /// rounding, the result of this initializer is `nil`. In particular,
  /// passing NaN as `other` always results in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: CGFloat) {
    self = BFloat16(other)
    guard CGFloat(self) == other else { return nil }
  }
}

extension CGFloat {
  /// Creates a new instance that approximates the given value.
  /// - Parameter other: The value to use for the new instance.
  public init(_ other: BFloat16) {
    self.init(NativeType(other))
  }
  
  /// Creates a new instance initialized to the given value, if it can be
  /// represented without rounding.
  ///
  /// If `other` can't be represented as an instance of `Double` without
  /// rounding, the result of this initializer is `nil`. In particular,
  /// passing NaN as `other` always results in `nil`.
  ///
  /// - Parameter other: The value to use for the new instance.
  public init?(exactly other: BFloat16) {
    self.init(NativeType(other))
    guard BFloat16(self) == other else { return nil }
  }
}
#endif
