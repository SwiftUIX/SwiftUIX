//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(*, deprecated, renamed: "_AnyImage.Name")
public typealias ImageName = _AnyImage.Name

/// A portable representation of an image.
public enum _AnyImage: Hashable, @unchecked Sendable {
    @frozen
    public enum Name: Hashable, @unchecked Sendable {
        case bundleResource(String, in: Bundle? = .main)
        case system(String)
        
        public static func system(_ symbol: SFSymbolName) -> Self {
            .system(symbol.rawValue)
        }
    }
    
    case appKitOrUIKitImage(AppKitOrUIKitImage)
    case named(Name)
    
    public init(systemName: String) {
        self = .named(.system(systemName))
    }
    
    public init(systemName: SFSymbolName) {
        self.init(systemName: systemName.rawValue)
    }
    
    public var appKitOrUIKitImage: AppKitOrUIKitImage? {
        switch self {
            case .appKitOrUIKitImage(let image):
                return image
            case .named(let name):
                return .init(named: name)
        }
    }
    
    public init?(_ image: AppKitOrUIKitImage?) {
        guard let image else {
            return nil
        }
        
        self = .appKitOrUIKitImage(image)
    }
}

extension _AnyImage: View {
    public var body: some View {
        switch self {
            case .appKitOrUIKitImage(let image):
                Image(image: image)
            case .named(let name):
                switch name {
                    case .bundleResource(let name, let bundle):
                        Image(name, bundle: bundle)
                    case .system(let name):
                        Image(_systemName: name)
                }
        }
    }
}

// MARK: - Conformances

extension _AnyImage: Codable {
    private enum _DecodingError: Error {
        case unsupported
    }

    private enum _EncodingError: Error {
        case unsupported
    }
        
    public init(from decoder: Decoder) throws {
        do {
            self = try .named(Name(from: decoder))
        } catch {
            throw _DecodingError.unsupported
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .named(let name):
                try name.encode(to: encoder)
            case .appKitOrUIKitImage:
                assertionFailure("unsupported")
                
                throw _EncodingError.unsupported
        }
    }
}

extension _AnyImage.Name: Codable {
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

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitImage {
    public convenience init?(named name: _AnyImage.Name) {
        switch name {
            case .bundleResource(let name, let bundle):
                self.init(named: name, in: bundle, with: nil)
            case .system(let name):
                self.init(systemName: name)
        }
    }
}
#elseif os(macOS)
extension AppKitOrUIKitImage {
    public convenience init?(named name: _AnyImage.Name) {
        switch name {
            case .bundleResource(let name, let bundle):
                if let bundle {
                    if let url = bundle.urlForImageResource(name) {
                        self.init(byReferencing: url)
                    } else if bundle == Bundle.main {
                        self.init(imageLiteralResourceName: name)
                    } else {
                        assertionFailure()
                        
                        return nil
                    }
                } else {
                    self.init(named: name)
                }
            case .system(let name):
                if #available(macOS 11.0, *) {
                    self.init(systemSymbolName: name, accessibilityDescription: nil)
                } else {
                    assertionFailure()
                    
                    return nil
                }
        }
    }
}
#endif

// MARK: - Helpers

extension Image {
    public init(_ name: _AnyImage.Name) {
        switch name {
            case .bundleResource(let name, let bundle):
                self.init(name, bundle: bundle)
            case .system(let name): do {
                if #available(OSX 10.16, *) {
                    self.init(systemName: name)
                } else {
                    assertionFailure()
                    
                    self.init(systemName: .nosign)
                }
            }
        }
    }
}
