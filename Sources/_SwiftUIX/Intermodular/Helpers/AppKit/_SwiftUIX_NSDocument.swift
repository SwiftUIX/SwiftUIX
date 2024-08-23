//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit

@_documentation(visibility: internal)
open class _SwiftUIX_NSDocument: NSDocument {
    @_documentation(visibility: internal)
public enum UnsafeFlag: Hashable, Sendable {
        case ephemeral
    }
    
    public var _unsafeFlags: Set<UnsafeFlag> = []
    
    public nonisolated var unsafeFlags: Set<UnsafeFlag> {
        MainActor.assumeIsolated {
            _unsafeFlags
        }
    }
    
    override open nonisolated func read(
        from fileWrapper: FileWrapper,
        ofType typeName: String
    ) throws {
        if self.unsafeFlags.contains(.ephemeral) {
            return
        }
        
        return try super.read(from: fileWrapper, ofType: typeName)
    }
    
    open override func data(
        ofType typeName: String
    ) throws -> Data {
        if self.unsafeFlags.contains(.ephemeral) {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        return try super.data(ofType: typeName)
    }
    
    open override func read(
        from data: Data,
        ofType typeName: String
    ) throws {
        if self.unsafeFlags.contains(.ephemeral) {
            return
        }
    }
}

#endif
