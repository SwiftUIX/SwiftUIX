//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

public protocol _AppKitOrUIKitRepresented: AppKitOrUIKitResponder {    
    var representationStateFlags: _AppKitOrUIKitRepresentationStateFlags { get set }
    var representationCache: _AppKitOrUIKitRepresentationCache { get set }
}

public struct _AppKitOrUIKitRepresentationStateFlags: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let updateInProgress = Self(rawValue: 1 << 0)
    public static let didUpdateAtLeastOnce = Self(rawValue: 1 << 1)
    public static let dismantled = Self(rawValue: 1 << 2)
}

public struct _AppKitOrUIKitRepresentationCache: ExpressibleByNilLiteral {
    public enum Attribute {
        case intrinsicContentSize
    }
    
    var _cachedIntrinsicContentSize: CGSize? = nil
    var _sizeThatFitsCache: [AppKitOrUIKitLayoutSizeProposal: CGSize] = [:]
    
    public init(nilLiteral: ()) {
        
    }
    
    mutating func invalidate(_ attribute: Attribute) {
        switch attribute {
            case .intrinsicContentSize:
                _cachedIntrinsicContentSize = nil
                _sizeThatFitsCache = [:]
        }
    }
}

#endif
