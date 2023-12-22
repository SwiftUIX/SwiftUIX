//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public struct _CocoaListPreferences: Sendable {
    public var cell: Cell = nil
    
    mutating func mergeInPlace(with other: Self) {
        self.cell = other.cell
    }
}

extension _CocoaListPreferences {
    public struct Cell: Sendable {
        public enum SizingOptions: Sendable {
            public enum Custom: Sendable {
                case indexPath(@Sendable (IndexPath) -> OptionalDimensions)
            }
            
            case auto
            case fixed(width: CGFloat?, height: CGFloat?)
            case custom(Custom)
        }
        
        public var sizingOptions: SizingOptions = .auto
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
