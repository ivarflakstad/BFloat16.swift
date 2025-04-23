//
//  BFloat16+Numeric.swift
//  BFloat16
//

#if SWIFT_PACKAGE
  import bfloat16_c
#endif

extension BFloat16: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Float.IntegerLiteralType) {
    self = BFloat16(Float(integerLiteral: value))
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

extension BFloat16: Numeric {
  public init?<T>(exactly source: T) where T: BinaryInteger {
    let val = Float(exactly: source)
    if val == nil {
      return nil
    }
    self = BFloat16(val!)
  }

  public var magnitude: BFloat16 {
    BFloat16(bf16_abs(bf16_t(self)))
  }

  public static func * (lhs: BFloat16, rhs: BFloat16) -> BFloat16 {
    BFloat16(bf16_mul(bf16_t(lhs), bf16_t(rhs)))
  }

  public static func *= (lhs: inout BFloat16, rhs: BFloat16) {
    lhs = lhs * rhs
  }
}

extension BFloat16: SignedNumeric {
  prefix public static func - (operand: Self) -> Self {
    BFloat16(bf16_neg(bf16_t(operand)))
  }
}
