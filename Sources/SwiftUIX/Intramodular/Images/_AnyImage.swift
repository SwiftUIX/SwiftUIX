//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(*, deprecated, renamed: "_AnyImage.Name")
public typealias ImageName = _AnyImage.Name

/// A portable representation of an image.
@frozen
public struct _AnyImage: Hashable, @unchecked Sendable {
    @frozen
    public enum Name: Hashable, @unchecked Sendable {
        case bundleResource(String, in: Bundle? = .main)
        case system(String)
        
        public static func system(_ symbol: SFSymbolName) -> Self {
            .system(symbol.rawValue)
        }
    }
    
    public enum Payload: Hashable {
        case appKitOrUIKitImage(AppKitOrUIKitImage)
        case named(Name)
    }
    
    let payload: Payload
    
    var resizable: Bool?
    var _preferredSize: OptionalDimensions = nil
    
    public init(payload: Payload) {
        self.payload = payload
    }
    
    public init(named name: Name) {
        self.init(payload: .named(name))
    }
}

extension _AnyImage {
    public func resizable(
        _ resizable: Bool
    ) -> Self {
        var result = self
        
        result.resizable = resizable
        
        return result
    }
    
    public func _preferredSize(
        _ size: OptionalDimensions
    ) -> Self {
        var result = self
        
        result._preferredSize = size
        
        return result
    }
    
    public func _preferredSize(
        _ size: CGSize?
    ) -> Self {
        self._preferredSize(OptionalDimensions(size))
    }
}

extension _AnyImage {
    public var _SwiftUI_image: Image {
        let result: Image = {
            switch payload {
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
        }()
        
        return result.resizable(resizable)
    }
    
    public var appKitOrUIKitImage: AppKitOrUIKitImage? {
        switch payload {
            case .appKitOrUIKitImage(let image):
                return image
            case .named(let name):
                return AppKitOrUIKitImage(named: name)
        }
    }
}

extension _AnyImage {
    public var jpegData: Data? {
        switch payload {
            case .appKitOrUIKitImage:
                return appKitOrUIKitImage?._SwiftUIX_jpegData
            case .named:
                return appKitOrUIKitImage?._SwiftUIX_jpegData
        }
    }
}

// MARK: - Initializers

extension _AnyImage {
    public init?(_ image: AppKitOrUIKitImage?) {
        guard let image else {
            return nil
        }
        
        self.init(payload: .appKitOrUIKitImage(image))
    }
    
    public init(_ image: AppKitOrUIKitImage) {
        self.init(payload: .appKitOrUIKitImage(image))
    }
    
    public init(systemName: String) {
        self.init(payload: .named(.system(systemName)))
    }
    
    public init(systemName: SFSymbolName) {
        self.init(systemName: systemName.rawValue)
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
            self.init(payload: try Payload.named(Name(from: decoder)))
        } catch {
            throw _DecodingError.unsupported
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch payload {
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

extension _AnyImage: View {
    public var body: some View {
        _SwiftUI_image
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
    
    public init(_ image: _AnyImage) {
        switch image.payload {
            case .appKitOrUIKitImage(let image):
                self.init(image: image)
            case .named(let name):
                self.init(name)
        }
    }
    
    @_disfavoredOverload
    public init(image: _AnyImage) {
        self.init(image)
    }
}
