//
//  BFloat16+SIMD.swift
//  BFloat16
//

extension BFloat16 : SIMDScalar {
  
  public typealias SIMDMaskScalar = Int16
  
  /// Storage for a vector of two brain floating-point values.
  @frozen @_alignment(4) public struct SIMD2Storage : SIMDStorage, Sendable {
    public var _value: UInt16.SIMD2Storage
    
    /// The number of scalars, or elements, in the vector.
    @_transparent public var scalarCount: Swift.Int {
      @_transparent get {
        _value.scalarCount
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
        _value.scalarCount
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
        _value.scalarCount
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
        _value.scalarCount
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
        _value.scalarCount
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
        _value.scalarCount
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
