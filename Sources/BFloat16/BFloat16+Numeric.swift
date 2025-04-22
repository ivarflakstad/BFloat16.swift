//
//  BFloat16+Numeric.swift
//  BFloat16
//
//  Created by Ivar Flakstad on 21/04/2025.
//

#if SWIFT_PACKAGE
import bfloat16_c
#endif

extension BFloat16: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: UInt16) {
    self = BFloat16(Float(value))
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
  prefix public static func - (operand: Self) -> Self {
    return BFloat16(bf16_neg(bf16_t(operand)))
  }
}
