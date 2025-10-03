//
//  BFloatTests.swift
//  BFloatTests
//
import Foundation
import PropertyBased
import Testing

@testable import BFloat16

extension Gen<BFloat16> {
  static var bfloat16 = Gen<UInt16>.value(in: 0...32639).map {
    BFloat16(bitPattern: $0)
  }
}

enum UnaryOp: CaseIterable {
  case neg, abs, sqrt, ceil, floor, round, trunc, modf, frexp
}

enum BinaryOp: CaseIterable {
  case add, sub, mul, div, remainder
}

enum TernaryOp: CaseIterable {
  case fma
}

enum OrdOp: CaseIterable {
  case gt, gte, lt, lte
}

@Suite
final class BFloat16Tests {
  @Test func testInit() {
    #expect(Float() == Float(BFloat16()))
    #expect(BFloat16.zero == BFloat16())
    #expect(BFloat16.zero == BFloat16(0))
    #expect(BFloat16.zero == BFloat16(0.0))
    #expect(BFloat16.one == BFloat16(1))
    #expect(BFloat16.one == BFloat16(1.0))
    #expect(BFloat16.zero.sign == .plus)
    #expect(BFloat16.negativeOne == BFloat16(-1.0))
    #expect(BFloat16.negativeZero == BFloat16(-0.0))
    #expect(BFloat16.negativeZero.sign == .minus)
    #expect(BFloat16.infinity == BFloat16(Float.infinity))
    #expect(-BFloat16.infinity == BFloat16(-Float.infinity))

    #expect(BFloat16(exactly: 200 as Int) == BFloat16(200.0))
    #expect(BFloat16(exactly: Float(7.5)) == BFloat16(7.5))
    #expect(BFloat16(exactly: Double(7.5)) == BFloat16(7.5))
    #expect(BFloat16(exactly: CGFloat(7.5)) == BFloat16(7.5))
    #expect(BFloat16(exactly: 7.0001 as Float) == nil)

    #expect(BFloat16(-Float(1.0)).sign == .minus)
    #expect(BFloat16(Float(1.0)).sign == .plus)
    #expect(BFloat16(Float.nan).isNaN)
    #expect(BFloat16(exactly: Float.nan) == nil)
    #expect(BFloat16(exactly: Double.nan) == nil)
    #expect(BFloat16(exactly: CGFloat.nan) == nil)

    #expect(BFloat16.leastNonzeroMagnitude.bitPattern == 1)
    #expect(BFloat16.infinity.nextDown == BFloat16.greatestFiniteMagnitude)
    #expect(BFloat16.infinity.isFinite == false)
    #expect(BFloat16.greatestFiniteMagnitude.isFinite)
  }

  @Test func testToFloat() {
    let exact = BFloat16(7.0)
    #expect(Float(exact) == 7.0)

    #expect(Float(exactly: exact) == Float(exact))
    #expect(CGFloat(exactly: exact) == CGFloat(exact))
    #expect(Float(Double(exact)) == Float(exact))
    #expect(Double(exactly: exact) == Double(exact))

    // 7.1 is NOT exactly representable in 16-bit, it's rounded
    let inexact = BFloat16(7.1)
    let diff = abs(Float(inexact) - 7.1)
    // diff must be <= 4 * EPSILON, as 7 has two more significant bits than 1
    #expect(diff <= 4.0 * Float(BFloat16.ulpOfOne))

    let tinyFloat = Float(bitPattern: 0x0001_0000)
    #expect(Float(BFloat16(bitPattern: 0x0001)) == tinyFloat)
    #expect(Float(BFloat16(bitPattern: 0x0005)) == 5.0 * tinyFloat)

    #expect(BFloat16(bitPattern: 0x0001) == BFloat16(tinyFloat))
    #expect(BFloat16(bitPattern: 0x0005) == BFloat16(5.0 * tinyFloat))

    #expect(Float(exactly: BFloat16.nan) == nil)
    #expect(Double(exactly: BFloat16.nan) == nil)
    #expect(CGFloat(exactly: BFloat16.nan) == nil)
  }

  @Test func testToInt() {
    let exact = BFloat16(7.0)
    #expect(Int(exact) == 7)
    #expect(Int(exactly: exact) == 7)

    let inexact = BFloat16(6.5)
    #expect(Int(inexact) == 6)
    #expect(Int(exactly: inexact) == nil)
    #expect(Int(exactly: BFloat16.nan) == nil)
  }

  @Test func testNan() {
    #expect(BFloat16.nan != BFloat16.nan)
    #expect(!(BFloat16.nan > BFloat16.nan))
    #expect(!(BFloat16.nan < BFloat16.nan))

    #expect(BFloat16(Float.nan).isNaN)
    #expect(BFloat16(Float.signalingNaN).isNaN)
    #expect(BFloat16(-Float.nan).isNaN)
    #expect(BFloat16.nan.isNaN)
    #expect(!BFloat16.nan.isSignalingNaN)
    #expect(BFloat16.signalingNaN.isNaN)
    #expect(BFloat16.signalingNaN.isSignalingNaN)
  }

  @Test func testComparisons() async {
    #expect(BFloat16.zero == BFloat16.zero)
    #expect(BFloat16.zero == BFloat16.negativeZero)
    #expect(BFloat16.zero < BFloat16.one)

    await propertyCheck(input: Gen.bfloat16) { i in
      #expect(i.isEqual(to: i), "BFloat16 Equality is Reflexive")
    }
  }

  @Test func testRounding() {
    #expect(BFloat16(Float(bitPattern: 0x0000000_0001)) == 0.0)

    #expect(
      BFloat16(250.49).bitPattern == BFloat16(250.0).bitPattern
    )
    #expect(
      BFloat16(250.50).bitPattern == BFloat16(250.0).bitPattern
    )
    #expect(
      BFloat16(250.51).bitPattern == BFloat16(251.0).bitPattern
    )
    #expect(
      BFloat16(251.49).bitPattern == BFloat16(251.0).bitPattern
    )
    #expect(
      BFloat16(251.50).bitPattern == BFloat16(252.0).bitPattern
    )
    #expect(
      BFloat16(251.51).bitPattern == BFloat16(252.0).bitPattern
    )
    #expect(
      BFloat16(252.49).bitPattern == BFloat16(252.0).bitPattern
    )
    #expect(
      BFloat16(252.50).bitPattern == BFloat16(252.0).bitPattern
    )
    #expect(
      BFloat16(252.51).bitPattern == BFloat16(253.0).bitPattern
    )
  }

  func roundtrip(_ comment: Comment, block: (BFloat16) throws -> BFloat16?) async {
    await propertyCheck(input: Gen.bfloat16) { input in
      let roundtrip = try #require(try block(input), comment)
      if input.isNaN {
        #expect(roundtrip.isNaN && input.sign == roundtrip.sign, comment)
      } else {
        #expect(input == roundtrip, comment)
      }
    }
  }

  @Test func testRoundtripIdentity() async {
    await roundtrip("BFloat16 roundtrip identity check") {
      BFloat16(Float($0))
    }
  }

  @Test func testRoundtripCodable() async {
    await roundtrip("BFloat16 roundtrip codable") {
      let coded = try JSONEncoder().encode($0)
      return try JSONDecoder().decode(BFloat16.self, from: coded)
    }
  }

  @Test func testRoundtripStringConversion() async {
    await roundtrip("BFloat16 roundtrip string conversion") {
      BFloat16($0.description)
    }
  }

  @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
  @Test func testRoundtripAtomic() async {
    await roundtrip("BFloat16 roundtrip identity check") {
      BFloat16.decodeAtomicRepresentation(BFloat16.encodeAtomicRepresentation($0))
    }
  }

  @Test func testUnaryOperations() async {
    await propertyCheck(input: Gen.bfloat16, Gen<UnaryOp>.case) { x, op in
      switch op {
      case .neg:
        #expect(-x == BFloat16(-Float(x)))
      case .abs:
        #expect(abs(x) == BFloat16(abs(Float(x))))
      case .sqrt:
        #expect(sqrt(x) == BFloat16(sqrt(Float(x))))
      case .ceil:
        #expect(ceil(x) == BFloat16(ceil(Float(x))))
      case .floor:
        #expect(floor(x) == BFloat16(floor(Float(x))))
      case .round:
        #expect(round(x) == BFloat16(round(Float(x))))
      case .trunc:
        #expect(trunc(x) == BFloat16(trunc(Float(x))))
      case .modf:
        let (bf_i, bf_f) = modf(x)
        let (i, f) = modf(Float(x))
        #expect(bf_i == BFloat16(i) && bf_f == BFloat16(f))
      case .frexp:
        let (bf_f, bf_i) = frexp(x)
        guard x.isFinite && x != 0 else {
          #expect(x == bf_f && bf_i == 0)
          return
        }
        #expect(bf_f == x.significand / 2 && bf_i == x.exponent + 1)
      }
    }
  }

  @Test func testBinaryOperations() async {
    await propertyCheck(input: Gen.bfloat16, Gen.bfloat16, Gen<BinaryOp>.case) { a, b, op in
      switch op {
      case .add:
        #expect(a + b == BFloat16(Float(a) + Float(b)))
      case .sub:
        #expect(a - b == BFloat16(Float(a) - Float(b)))
      case .mul:
        #expect(a * b == BFloat16(Float(a) * Float(b)))
      case .div:
        guard _fastPath(b != 0.0) else { return }
        #expect(a / b == BFloat16(Float(a) / Float(b)))
      case .remainder:
        guard _fastPath(b != 0.0) else { return }
        #expect(remainder(a, b) == BFloat16(remainder(Float(a), Float(b))))
      }
    }
  }

  @Test func testTernaryOperations() async {
    await propertyCheck(input: Gen.bfloat16, Gen.bfloat16, Gen.bfloat16, Gen<TernaryOp>.case) {
      a, b, c, op in
      switch op {
      case .fma:
        #expect(fma(a, b, c) == BFloat16(fma(Float(a), Float(b), Float(c))))
      }
    }
  }

  @Test func testOrdering() async {
    await propertyCheck(input: Gen.bfloat16, Gen.bfloat16, Gen<OrdOp>.case) { a, b, op in
      switch op {
      case .gt:
        #expect((a > b) == (Float(a) > Float(b)))
      case .gte:
        #expect((a >= b) == (Float(a) >= Float(b)))
      case .lt:
        #expect((a < b) == (Float(a) < Float(b)))
      case .lte:
        #expect((a <= b) == (Float(a) <= Float(b)))
      }
    }
  }

  @Test func testSIMD() {
    var actual = SIMD4<BFloat16>(1.0, 2.0, 3.0, 4.0)
    for _ in 0...10 {
      actual += actual
    }
    let expected = SIMD4<BFloat16>(2048.0, 4096.0, 6144.0, 8192.0)
    #expect(actual == expected)
  }
}
