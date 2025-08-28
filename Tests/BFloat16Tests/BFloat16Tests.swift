//
//  BFloatTests.swift
//  BFloatTests
//
//  Created by Ivar Flakstad on 23/02/2024.
//
import SwiftCheck
import XCTest
import Foundation

@testable import BFloat16

extension BFloat16: Arbitrary {
  static func u16ToBfloat(u: UInt16) -> BFloat16 {
    BFloat16(bitPattern: u)
  }

  public static var arbitrary: Gen<BFloat16> {
    return Gen.sized {
      n in
      Gen<UInt16>
        .choose((0, UInt16(truncatingIfNeeded: min(n, 32639))))
        .map(u16ToBfloat)
    }
  }
}

enum UnaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case neg, abs, sqrt, ceil, floor, round, trunc, modf, frexp
}

enum BinaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case add, sub, mul, div, remainder
}

enum TernaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case fma
}

enum OrdOp: CaseIterable {
  var id: Self {
    return self
  }
  case gt, gte, lt, lte
}

extension UnaryOp: Arbitrary {
  public static var arbitrary: Gen<UnaryOp> {
    return Gen.sized {
      n in Gen<UnaryOp>.fromElements(of: UnaryOp.allCases)
    }
  }
}

extension BinaryOp: Arbitrary {
  public static var arbitrary: Gen<BinaryOp> {
    return Gen.sized {
      n in Gen<BinaryOp>.fromElements(of: BinaryOp.allCases)
    }
  }
}

extension TernaryOp: Arbitrary {
  public static var arbitrary: Gen<TernaryOp> {
    return Gen.sized {
      n in Gen<TernaryOp>.fromElements(of: TernaryOp.allCases)
    }
  }
}

extension OrdOp: Arbitrary {
  public static var arbitrary: Gen<OrdOp> {
    return Gen.sized {
      n in Gen<OrdOp>.fromElements(of: OrdOp.allCases)
    }
  }
}

final class BFloat16Tests: XCTestCase {
  func testInit() {
    XCTAssertEqual(Float(), Float(BFloat16()))
    XCTAssertEqual(BFloat16.zero, BFloat16())
    XCTAssertEqual(BFloat16.zero, BFloat16(0))
    XCTAssertEqual(BFloat16.zero, BFloat16(0.0))
    XCTAssertEqual(BFloat16.one, BFloat16(1))
    XCTAssertEqual(BFloat16.one, BFloat16(1.0))
    XCTAssertEqual(BFloat16.zero.sign, .plus)
    XCTAssertEqual(BFloat16.negativeOne, BFloat16(-1.0))
    XCTAssertEqual(BFloat16.negativeZero, BFloat16(-0.0))
    XCTAssertEqual(BFloat16.negativeZero.sign, .minus)
    XCTAssertEqual(BFloat16.infinity, BFloat16(Float.infinity))
    XCTAssertEqual(-BFloat16.infinity, BFloat16(-Float.infinity))
      
    XCTAssertEqual(BFloat16(exactly: 200 as Int), BFloat16(200.0))
    XCTAssertEqual(BFloat16(exactly: Float(7.5)), BFloat16(7.5))
    XCTAssertEqual(BFloat16(exactly: Double(7.5)), BFloat16(7.5))
    XCTAssertEqual(BFloat16(exactly: CGFloat(7.5)), BFloat16(7.5))
    XCTAssertNil(BFloat16(exactly: 7.0001 as Float))

    XCTAssertEqual(BFloat16(-Float(1.0)).sign, .minus)
    XCTAssertEqual(BFloat16(Float(1.0)).sign, .plus)
    XCTAssert(BFloat16(Float.nan).isNaN)
    XCTAssertNil(BFloat16(exactly: Float.nan))
    XCTAssertNil(BFloat16(exactly: Double.nan))
    XCTAssertNil(BFloat16(exactly: CGFloat.nan))
      
    XCTAssertEqual(BFloat16.leastNonzeroMagnitude.bitPattern, 1)
    XCTAssertEqual(BFloat16.infinity.nextDown, BFloat16.greatestFiniteMagnitude)
    XCTAssertFalse(BFloat16.infinity.isFinite)
    XCTAssertTrue(BFloat16.greatestFiniteMagnitude.isFinite)
  }

  func testToFloat() {
    let exact = BFloat16(7.0)
    XCTAssertEqual(Float(exact), 7.0)

    XCTAssertEqual(Float(exactly: exact), Float(exact))
    XCTAssertEqual(CGFloat(exactly: exact), CGFloat(exact))
    XCTAssertEqual(Float(Double(exact)), Float(exact))
    XCTAssertEqual(Double(exactly: exact), Double(exact))
      
    // 7.1 is NOT exactly representable in 16-bit, it's rounded
    let inexact = BFloat16(7.1)
    let diff = abs(Float(inexact) - 7.1)
    // diff must be <= 4 * EPSILON, as 7 has two more significant bits than 1
    XCTAssert(diff <= 4.0 * Float(BFloat16.ulpOfOne))

    let tinyFloat = Float(bitPattern: 0x0001_0000)
    XCTAssertEqual(Float(BFloat16(bitPattern: 0x0001)), tinyFloat)
    XCTAssertEqual(Float(BFloat16(bitPattern: 0x0005)), 5.0 * tinyFloat)

    XCTAssertEqual(BFloat16(bitPattern: 0x0001), BFloat16(tinyFloat))
    XCTAssertEqual(BFloat16(bitPattern: 0x0005), BFloat16(5.0 * tinyFloat))
      
    XCTAssertNil(Float(exactly: BFloat16.nan))
    XCTAssertNil(Double(exactly: BFloat16.nan))
    XCTAssertNil(CGFloat(exactly: BFloat16.nan))
  }
    
  func testToInt() {
    let exact = BFloat16(7.0)
    XCTAssertEqual(Int(exact), 7)
    XCTAssertEqual(Int(exactly: exact), 7)
      
    let inexact = BFloat16(6.5)
    XCTAssertEqual(Int(inexact), 6)
    XCTAssertNil(Int(exactly: inexact))
    XCTAssertNil(Int(exactly: BFloat16.nan))
  }

  func testNan() {
    XCTAssertNotEqual(BFloat16.nan, BFloat16.nan)
    XCTAssertFalse(BFloat16.nan > BFloat16.nan)
    XCTAssertFalse(BFloat16.nan < BFloat16.nan)

    XCTAssert(BFloat16(Float.nan).isNaN)
    XCTAssert(BFloat16(Float.signalingNaN).isNaN)
    XCTAssert(BFloat16(-Float.nan).isNaN)
    XCTAssert(BFloat16.nan.isNaN)
    XCTAssert(!BFloat16.nan.isSignalingNaN)
    XCTAssert(BFloat16.signalingNaN.isNaN)
    XCTAssert(BFloat16.signalingNaN.isSignalingNaN)
  }

  func testComparisons() {
    XCTAssertEqual(BFloat16.zero, BFloat16.zero)
    XCTAssertEqual(BFloat16.zero, BFloat16.negativeZero)
    XCTAssertLessThan(BFloat16.zero, BFloat16.one)

    property("BFloat16 Equality is Reflexive")
      <- forAll { (i: BFloat16) in
        return i.isEqual(to: i)
      }
  }

  func testRounding() {
    XCTAssertEqual(BFloat16(Float(bitPattern: 0x0000000_0001)), 0.0)

    XCTAssertEqual(
      BFloat16(250.49).bitPattern,
      BFloat16(250.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(250.50).bitPattern,
      BFloat16(250.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(250.51).bitPattern,
      BFloat16(251.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(251.49).bitPattern,
      BFloat16(251.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(251.50).bitPattern,
      BFloat16(252.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(251.51).bitPattern,
      BFloat16(252.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(252.49).bitPattern,
      BFloat16(252.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(252.50).bitPattern,
      BFloat16(252.0).bitPattern
    )
    XCTAssertEqual(
      BFloat16(252.51).bitPattern,
      BFloat16(253.0).bitPattern
    )
  }

  func testRoundtripIdentity() {
    property("BFloat16 roundtrip identity check")
      <- forAll { (val: BFloat16) in
        let roundtrip = BFloat16(Float(val))
        if val.isNaN {
          return roundtrip.isNaN && val.sign == roundtrip.sign
        } else {
          return val == roundtrip
        }
      }
  }

  func testRoundtripStringConversion() {
    property("BFloat16 roundtrip string conversion")
      <- forAll { (val: BFloat16) in
        guard let roundtrip = BFloat16(val.description) else {
          return false
        }
        if val.isNaN {
          return roundtrip.isNaN && val.sign == roundtrip.sign
        } else {
          return val == roundtrip
        }
      }
  }

  func testUnaryOperations() {
    property("BFloat16 unary ops")
      <- forAll {
        (x: BFloat16, op: UnaryOp) in
        switch op {
        case .neg:
          return -x == BFloat16(-Float(x))
        case .abs:
          return abs(x) == BFloat16(abs(Float(x)))
        case .sqrt:
          return sqrt(x) == BFloat16(sqrt(Float(x)))
        case .ceil:
          return ceil(x) == BFloat16(ceil(Float(x)))
        case .floor:
          return floor(x) == BFloat16(floor(Float(x)))
        case .round:
          return round(x) == BFloat16(round(Float(x)))
        case .trunc:
          return trunc(x) == BFloat16(trunc(Float(x)))
        case .modf:
          let (bf_i, bf_f) = modf(x)
          let (i, f) = modf(Float(x))
          return bf_i == BFloat16(i) && bf_f == BFloat16(f)
        case .frexp:
          let (bf_f, bf_i) = frexp(x)
          guard x.isFinite && x != 0 else {
            return x == bf_f && bf_i == 0
          }
          return bf_f == x.significand / 2 && bf_i == x.exponent + 1
        }
      }
  }

  func testBinaryOperations() {
    property("BFloat16 binary ops")
      <- forAll {
        (a: BFloat16, b: BFloat16, op: BinaryOp) in
        switch op {
        case .add:
          return a + b == BFloat16(Float(a) + Float(b))
        case .sub:
          return a - b == BFloat16(Float(a) - Float(b))
        case .mul:
          return a * b == BFloat16(Float(a) * Float(b))
        case .div:
          guard _fastPath(b != 0.0) else { return true }
          return a / b == BFloat16(Float(a) / Float(b))
        case .remainder:
          guard _fastPath(b != 0.0) else { return true }
          return remainder(a, b) == BFloat16(remainder(Float(a), Float(b)))
        }
      }
  }

  func testTernaryOperations() {
    property("BFloat16 ternary ops")
      <- forAll {
        (a: BFloat16, b: BFloat16, c: BFloat16, op: TernaryOp) in
        switch op {
        case .fma:
          return fma(a, b, c) == BFloat16(fma(Float(a), Float(b), Float(c)))
        }
      }
  }

  func testOrdering() {
    property("BFloat16 ordering")
      <- forAll {
        (a: BFloat16, b: BFloat16, op: OrdOp) in
        switch op {
        case .gt:
          return (a > b) == (Float(a) > Float(b))
        case .gte:
          return (a >= b) == (Float(a) >= Float(b))
        case .lt:
          return (a < b) == (Float(a) < Float(b))
        case .lte:
          return (a <= b) == (Float(a) <= Float(b))
        }
      }
  }

  func testSIMD() {
    var actual = SIMD4<BFloat16>(1.0, 2.0, 3.0, 4.0)
    for _ in 0...10 {
      actual += actual
    }
    let expected = SIMD4<BFloat16>(2048.0, 4096.0, 6144.0, 8192.0)
    XCTAssertEqual(actual, expected)
  }
}
