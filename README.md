# BFloat16

Brain floating point type for Swift.

Inspired by floating point implementations in
 * [Swift standard library](https://github.com/apple/swift/blob/main/stdlib/public/core/FloatingPointTypes.swift.gyb)
 * [SomeRandomiOSDev/Half](https://github.com/SomeRandomiOSDev/Half)
 * [starkat99/half-rs](https://github.com/VoidStarKat/half-rs/blob/main/src/bfloat.rs)

To install via the Swift Package Manager add the following line to your `Package.swift` file's `dependencies`:

```swift
.package(url: "https://github.com/ivarflakstad/BFloat16.swift.git", from: "1.0.0")
```

## Usage

Import **BFloat16**:
```swift
import BFloat16
```

After importing, use the imported `BFloat16` type exactly like you'd use Swift's builtin `Float`, `Double`, or `Float80` types. 

```swift
func printDouble(value: BFloat16) {
    print(value * 2.0)
}
printDouble(7.891)

> 15.782
```

Also supports SIMD
```swift
var actual = SIMD4<BFloat16>(1.0, 2.0, 3.0, 4.0)
for _ in 0...10 {
  actual += actual
}
let expected = SIMD4<BFloat16>(2048.0, 4096.0, 6144.0, 8192.0)
assert(actual == expected)
```

## License

**BFloat16** is available under the MIT license. See the `LICENSE` file for more info.
