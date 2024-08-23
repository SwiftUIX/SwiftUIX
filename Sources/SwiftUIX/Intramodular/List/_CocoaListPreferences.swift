//
// Copyright (c) Vatsal Manot
//

import SwiftUI

@_documentation(visibility: internal)
public struct _CocoaListPreferences: Sendable {
    public var cell: Cell = nil
    
    mutating func mergeInPlace(with other: Self) {
        self.cell.mergeInPlace(with: other.cell)
    }
    
    func mergingInPlace(with other: Self) -> Self {
        var result = self
        
        result.mergeInPlace(with: other)
        
        return result
    }
}

extension _CocoaListPreferences {
    public struct Cell: Sendable {
        public struct ViewHostingOptions: Hashable, Sendable {
            public var useAutoLayout: Bool = true
            public var detachHostingView: Bool = false
        }
        
        @_documentation(visibility: internal)
public enum SizingOptions: Sendable {
            @_documentation(visibility: internal)
public enum Custom: Sendable {
                case indexPath(@Sendable (IndexPath) -> OptionalDimensions)
            }
            
            case auto
            case fixed(width: CGFloat?, height: CGFloat?)
            case custom(Custom)
        }
        
        public var viewHostingOptions: ViewHostingOptions = .init()
        public var sizingOptions: SizingOptions = .auto
        
        mutating func mergeInPlace(with other: Self) {
            self.viewHostingOptions = other.viewHostingOptions
            self.sizingOptions = other.sizingOptions
        }
    }
}

// MARK: - Conformances

extension _CocoaListPreferences: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        
    }
    
}
extension _CocoaListPreferences.Cell: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        
    }
}

// MARK: - Auxiliary

extension EnvironmentValues {
    struct _CocoaListPreferencesKey: SwiftUI.EnvironmentKey {
        static var defaultValue: _CocoaListPreferences = nil
    }
    
    @_spi(Internal)
    public var _cocoaListPreferences: _CocoaListPreferences {
        get {
            self[_CocoaListPreferencesKey.self]
        } set {
            self[_CocoaListPreferencesKey.self] = newValue
        }
    }
}
