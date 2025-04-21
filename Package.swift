// swift-tools-version: 5.10
//
//  Package.swift
//  BFloat16
//
//  The MIT License (MIT)
//
//  Copyright (c) 2024 Ivar Flakstad
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import PackageDescription

let package = Package(
  name: "BFloat16",
  products: [
    .library(name: "BFloat16", targets: ["BFloat16", "bfloat16_c"]),
  ],
  dependencies: [
    .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0")
  ],
  targets: [
    .target(name: "bfloat16_c"),
    .target(
      name: "BFloat16",
      dependencies: ["bfloat16_c"],
    ),
    .testTarget(
      name: "BFloat16Tests",
      dependencies: ["BFloat16", "SwiftCheck"]
    )
  ]
)
