//
//  BFloat16.swift
//  BFloat16
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
    _value = 0;
  }
  
  @_transparent @inlinable @inline(__always)
  init(_ value: bf16_t) {
    _value = value
  }
  
  @_transparent @inlinable @inline(__always)
  init(bitPattern: UInt16) {
    _value = bf16_from(bitPattern)
  }
  
  @inlinable public static var zero: BFloat16 {
    BFloat16()
  }
  
  @inlinable public static var neg_zero: BFloat16 {
    BFloat16(bitPattern: 0x8000)
  }
  
  @inlinable public static var one: BFloat16 {
    BFloat16(bitPattern: 0x3F80)
  }
  
  @inlinable public static var neg_one: BFloat16 {
    BFloat16(bitPattern: 0xBF80)
  }
  
  @inlinable public static var epsilon: BFloat16 {
    BFloat16(bitPattern: 0x3C00)
  }
}


@inlinable public func abs(_ x: BFloat16) -> BFloat16 {
  return x.sign == .minus ? -x : x
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
