//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum ImageName: Hashable {
    case resource(String, bundle: Bundle? = .main)
    case system(String)
}

extension ImageName {
    public static func system(_ symbol: SanFranciscoSymbolName) -> Self {
        .system(symbol.rawValue)
    }
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIImage {
    public convenience init?(named name: ImageName) {
        switch name {
            case .resource(let name, let bundle):
                self.init(named: name, in: bundle, with: nil)
            case .system(let name):
                self.init(systemName: name)
        }
    }
}

#endif

#if os(macOS)

extension NSImage {
    public convenience init?(named name: ImageName) {
        switch name {
            case .resource(let name, let bundle): do {
                if let bundle = bundle, let _ = bundle.image(forResource: name) {
                    self.init(named: name) // FIXME
                } else {
                    self.init(named: name)
                }
            }
            case .system(let name): do {
                #if swift(>=5.3)
                if #available(OSX 10.16, *) {
                    // self.init(systemSymbolName: name, accessibilityDescription: nil)
                    _ = name
                    fatalError("Fuck Xcode 12 GM")
                } else {
                    fatalError("unimplemented")
                }
                #else
                fatalError("unimplemented")
                #endif
            }
        }
    }
}

#endif

// MARK: - Helpers -

extension Image {
    public init(_ name: ImageName) {
        switch name {
            case .resource(let name, let bundle):
                self.init(name, bundle: bundle)
            case .system(let name): do {
                if #available(OSX 10.16, *) {
                    _ = name
                    // self.init(systemName: name)
                    fatalError()
                } else {
                    fatalError()
                }
            }
        }
    }
}
