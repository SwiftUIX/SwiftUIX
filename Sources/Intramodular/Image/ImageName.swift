//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public enum ImageName: Hashable {
    case bundleResource(String, in: Bundle? = .main)
    case system(String)
}

// MARK: - Conformances -

extension ImageName: Codable {
    struct _CodableRepresentation: Codable {
        enum ImageNameType: String, Codable {
            case bundleResource
            case system
        }
        
        let type: ImageNameType
        let name: String
        let bundleIdentifier: String?
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let decoded = try container.decode(_CodableRepresentation.self)
        
        switch decoded.type {
            case .bundleResource:
                self = .bundleResource(decoded.name, in: decoded.bundleIdentifier.flatMap(Bundle.init(identifier:)))
            case .system:
                self = .system(decoded.name)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .bundleResource(let name, let bundle):
                try container.encode(
                    _CodableRepresentation(
                        type: .bundleResource,
                        name: name,
                        bundleIdentifier: bundle?.bundleIdentifier
                    )
                )
            case .system(let name): do {
                try container.encode(
                    _CodableRepresentation(
                        type: .system,
                        name: name,
                        bundleIdentifier: nil
                    )
                )
            }
        }
    }
}

extension ImageName {
    public static func system(_ symbol: SFSymbolName) -> Self {
        .system(symbol.rawValue)
    }
}

// MARK: - Auxiliary Implementation -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIImage {
    public convenience init?(named name: ImageName) {
        switch name {
            case .bundleResource(let name, let bundle):
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
            case .bundleResource(let name, let bundle): do {
                if let bundle = bundle, let _ = bundle.image(forResource: name) {
                    self.init(named: name) // FIXME
                } else {
                    self.init(named: name)
                }
            }
            case .system(let name): do {
                if #available(OSX 10.16, *) {
                    self.init(systemSymbolName: name, accessibilityDescription: nil)
                } else {
                    fatalError("unimplemented")
                }
            }
        }
    }
}

#endif

// MARK: - Helpers -

extension Image {
    public init(_ name: ImageName) {
        switch name {
            case .bundleResource(let name, let bundle):
                self.init(name, bundle: bundle)
            case .system(let name): do {
                if #available(OSX 10.16, *) {
                    self.init(systemName: name)
                } else {
                    fatalError()
                }
            }
        }
    }
}
