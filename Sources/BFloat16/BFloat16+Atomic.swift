//
//  BFloat16+Atomic.swift
//  BFloat16
//

#if canImport(Synchronization)
import Synchronization

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
extension BFloat16: AtomicRepresentable {
    public static func encodeAtomicRepresentation(_ value: BFloat16) -> UInt16.AtomicRepresentation {
        UInt16.encodeAtomicRepresentation(value.bitPattern)
    }
    
    public static func decodeAtomicRepresentation(_ storage: consuming UInt16.AtomicRepresentation) -> BFloat16 {
        BFloat16(bitPattern: UInt16.decodeAtomicRepresentation(storage))
    }
}
#endif
