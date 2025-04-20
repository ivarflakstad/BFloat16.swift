//
//  BFloatTests.swift
//  BFloatTests
//
//  Created by Ivar Arning Flakstad on 23/02/2024.
//
import SwiftCheck
import XCTest
@testable import BFloat16

extension BFloat16 : Arbitrary {
  static func u16ToBfloat(u: UInt16) -> BFloat16 {
    BFloat16(bitPattern: u)
  }
  
  public static var arbitrary : Gen<BFloat16> {
    return Gen.sized {
      n in Gen<UInt16>
        .choose((0, UInt16(truncatingIfNeeded: min(n, 32639))))
        .map(u16ToBfloat)
    }
  }
}

enum UnaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case neg, abs, sqrt
}

enum BinaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case add, sub, mul, div
}

enum TernaryOp: CaseIterable {
  var id: Self {
    return self
  }
  case fma
}

extension UnaryOp : Arbitrary {
  public static var arbitrary : Gen<UnaryOp> {
    return Gen.sized {
      n in Gen<UnaryOp>.fromElements(of:UnaryOp.allCases)
    }
  }
}

extension BinaryOp : Arbitrary {
  public static var arbitrary : Gen<BinaryOp> {
    return Gen.sized {
      n in Gen<BinaryOp>.fromElements(of:BinaryOp.allCases)
    }
  }
}

extension TernaryOp : Arbitrary {
  public static var arbitrary : Gen<TernaryOp> {
    return Gen.sized {
      n in Gen<TernaryOp>.fromElements(of:TernaryOp.allCases)
    }
  }
}

final class BFloat16Tests: XCTestCase {
  func testFloatInit() {
    XCTAssertEqual(Float(), Float(BFloat16()))
    XCTAssertEqual(BFloat16.zero, BFloat16())
    XCTAssertEqual(BFloat16.zero, BFloat16(0))
    XCTAssertEqual(BFloat16.zero, BFloat16(0.0))
    XCTAssertEqual(BFloat16.one, BFloat16(1))
    XCTAssertEqual(BFloat16.one, BFloat16(1.0))
    XCTAssertEqual(BFloat16.zero.sign, .plus)
    XCTAssertEqual(BFloat16.neg_one, BFloat16(-1.0))
    XCTAssertEqual(BFloat16.neg_zero, BFloat16(-0.0))
    XCTAssertEqual(BFloat16.neg_zero.sign, .minus)
    XCTAssertEqual(BFloat16.infinity, BFloat16(Float.infinity))
    XCTAssertEqual(-BFloat16.infinity, BFloat16(-Float.infinity))
    
    XCTAssertEqual(BFloat16(-Float(1.0)).sign, .minus)
    XCTAssertEqual(BFloat16(Float(1.0)).sign, .plus)
    XCTAssert(BFloat16(Float.nan).isNaN)
  }
  
  func testToFloat() {
    let exact = BFloat16(7.0)
    XCTAssertEqual(exact.float(), 7.0)
    
    // 7.1 is NOT exactly representable in 16-bit, it's rounded
    let inexact = BFloat16(7.1)
    let diff = abs(inexact.float() - 7.1)
    // diff must be <= 4 * EPSILON, as 7 has two more significant bits than 1
    XCTAssert(diff <= 4.0 * BFloat16.epsilon.float());
    
    let tinyFloat = Float(bitPattern: 0x0001_0000);
    XCTAssertEqual(BFloat16(bitPattern: 0x0001).float(), tinyFloat)
    XCTAssertEqual(BFloat16(bitPattern: 0x0005).float(), 5.0 * tinyFloat)
    
    XCTAssertEqual(BFloat16(bitPattern: 0x0001), BFloat16(tinyFloat))
    XCTAssertEqual(BFloat16(bitPattern: 0x0005), BFloat16(5.0 * tinyFloat))
  }
  
  func testNanConversions() {
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
    XCTAssertLessThanOrEqual(BFloat16.neg_zero, BFloat16.zero)
    XCTAssertLessThan(BFloat16.zero, BFloat16.one)
    
    property("BFloat16 Equality is Reflexive") <- forAll { (i : BFloat16) in
      return i.isEqual(to: i)
    }
  }
  
  func testRounding() {
    XCTAssertEqual(BFloat16(Float(bitPattern: 0x0000000_0001)), 0.0)
    
    XCTAssertEqual(
      BFloat16(250.49).bitPattern,
      BFloat16(250.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(250.50).bitPattern,
      BFloat16(250.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(250.51).bitPattern,
      BFloat16(251.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(251.49).bitPattern,
      BFloat16(251.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(251.50).bitPattern,
      BFloat16(252.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(251.51).bitPattern,
      BFloat16(252.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(252.49).bitPattern,
      BFloat16(252.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(252.50).bitPattern,
      BFloat16(252.0).bitPattern
    );
    XCTAssertEqual(
      BFloat16(252.51).bitPattern,
      BFloat16(253.0).bitPattern
    );
  }
  
  func testRoundtripIdentity() {
    property("BFloat16 roundtrip identity check") <- forAll { (val: BFloat16) in
      let roundtrip = BFloat16(val.float());
      if val.isNaN{
        return roundtrip.isNaN && val.sign == roundtrip.sign
      } else {
        return val == roundtrip
      }
    }
  }
  
  func testUnaryOperations() {
    property("BFloat16 unary ops") <- forAll {
      (a: BFloat16, op: UnaryOp) in
      switch op {
      case .neg:
        return -a == BFloat16(-a.float())
      case .abs:
        return abs(a) == BFloat16(abs(a.float()))
      case .sqrt:
        return a.squareRoot() == BFloat16(a.float().squareRoot())
      }
    }
  }
  
  func testBinaryOperations() {
    property("BFloat16 binary ops") <- forAll {
      (a: BFloat16, b: BFloat16, op: BinaryOp) in
      switch op {
      case .add:
        return a + b == BFloat16(a.float() + b.float())
      case .sub:
        return a - b == BFloat16(a.float() - b.float())
      case .mul:
        return a * b == BFloat16(a.float() * b.float())
      case .div:
        guard _fastPath(b != 0.0) else { return true }
        return a / b == BFloat16(a.float() / b.float())
      }
    }
  }
  
  func testTernaryOperations() {
    property("BFloat16 ternary ops") <- forAll {
      (a: BFloat16, b: BFloat16, c: BFloat16, op: TernaryOp) in
      switch op {
      case .fma:
        return a.addingProduct(b, b) == BFloat16(a.float().addingProduct(b.float(), b.float()))
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
