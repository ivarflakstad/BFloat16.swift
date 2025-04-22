//
//  BFloat16+Codable.swift
//  BFloat16
//

extension BFloat16: Codable {
  
  /// Encodes this value into the given encoder.
  ///
  /// This function throws an error if any values are invalid for the given
  /// encoder's format.
  ///
  /// - Parameter encoder: The encoder to write data to.
  @_transparent
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(Float(self))
  }
  
  /// Creates a new instance by decoding from the given decoder.
  ///
  /// This initializer throws an error if reading from the decoder fails, or
  /// if the data read is corrupted or otherwise invalid.
  ///
  /// - Parameter decoder: The decoder to read data from.
  @_transparent
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let float = try container.decode(Float.self)
    
    guard float.isInfinite || float.isNaN || abs(float) <= Float(BFloat16.greatestFiniteMagnitude) else {
      throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Parsed number \(float) does not fit in \(type(of: self))."))
    }
    
    self.init(float)
  }
}
