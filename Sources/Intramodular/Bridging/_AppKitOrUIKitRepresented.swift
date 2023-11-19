//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import SwiftUI

public protocol _AppKitOrUIKitRepresented: AnyObject, AppKitOrUIKitResponder {
    var representatableStateFlags: _AppKitOrUIKitRepresentableStateFlags { get set }
    var representableCache: _AppKitOrUIKitRepresentableCache { get set }
    
    func _performOrSchedulePublishingChanges(_: @escaping () -> Void)
}

public struct _AppKitOrUIKitRepresentableStateFlags: OptionSet {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let updateInProgress = Self(rawValue: 1 << 0)
    public static let didUpdateAtLeastOnce = Self(rawValue: 1 << 1)
    public static let dismantled = Self(rawValue: 1 << 2)
}

public struct _AppKitOrUIKitRepresentableCache: ExpressibleByNilLiteral {
    public enum Attribute {
        case intrinsicContentSize
    }
    
    var _cachedIntrinsicContentSize: CGSize? = nil
    var _sizeThatFitsCache: [AppKitOrUIKitLayoutSizeProposal: CGSize] = [:]
    
    public init(nilLiteral: ()) {
        
    }
    
    public mutating func invalidate(_ attribute: Attribute) {
        switch attribute {
            case .intrinsicContentSize:
                _cachedIntrinsicContentSize = nil
                _sizeThatFitsCache = [:]
        }
    }
    
    public func sizeThatFits(proposal: AppKitOrUIKitLayoutSizeProposal) -> CGSize? {
        if let result = _sizeThatFitsCache[proposal] {
            return result
        } else if !_sizeThatFitsCache.isEmpty {
            if let targetSize = CGSize(proposal.size.target),
               let cached: CGSize = _sizeThatFitsCache.first(where: { $0.key.size.target.width == targetSize.width && $0.key.size.target.height == nil })?.value,
               cached.height <= targetSize.height
            {
                return cached
            }
        }
        
        return nil
    }
}

extension AppKitOrUIKitResponder {
    @objc open func _performOrSchedulePublishingChanges(
        @_implicitSelfCapture _ operation: @escaping () -> Void
    ) {
        if let responder = self as? _AppKitOrUIKitRepresented {
            if responder.representatableStateFlags.contains(.updateInProgress) {
                DispatchQueue.main.async {
                    operation()
                }
            } else {
                operation()
            }
        } else {
            operation()
        }
    }
}

extension _AppKitOrUIKitRepresented {
    public func _performOrSchedulePublishingChanges(
        @_implicitSelfCapture _ operation: @escaping () -> Void
    ) {
        if representatableStateFlags.contains(.updateInProgress) {
            DispatchQueue.main.async {
                operation()
            }
        } else {
            operation()
        }
    }
}

#endif
