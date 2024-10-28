//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import SwiftUI

@available(*, deprecated, renamed: "_AnyImage.Name")
public typealias ImageName = _AnyImage.Name

/// A portable representation of an image.
@frozen
@_documentation(visibility: internal)
public struct _AnyImage: Hashable, @unchecked Sendable {
    /// Represents the name or identifier of an image.
    @frozen
    @_documentation(visibility: internal)
    public enum Name: Hashable, @unchecked Sendable {
        /// An image resource from a bundle.
        case bundleResource(String, in: Bundle? = .main)
        /// A system image.
        case system(String)
        
        /// Creates a system image name from an SF Symbol name.
        public static func system(_ symbol: SFSymbolName) -> Self {
            .system(symbol.rawValue)
        }
    }
    
    /// Represents the underlying image data.
    @_documentation(visibility: internal)
    public enum Payload: Hashable {
        /// An AppKit or UIKit image.
        case appKitOrUIKitImage(AppKitOrUIKitImage)
        /// A named image.
        case named(Name)
    }
    
    /// The underlying image data.
    let payload: Payload
    
    /// Indicates whether the image is resizable.
    var resizable: Bool?
    /// The preferred size of the image.
    var _preferredSize: OptionalDimensions = nil
    
    /// Initializes an _AnyImage with the given payload.
    public init(payload: Payload) {
        self.payload = payload
    }
    
    /// Initializes an _AnyImage with the given name.
    public init(named name: Name) {
        self.init(payload: .named(name))
    }
}

extension _AnyImage {
    /// Sets the resizable property of the image.
    public func resizable(
        _ resizable: Bool
    ) -> Self {
        var result = self
        result.resizable = resizable
        return result
    }
    
    /// Sets the preferred size of the image.
    public func _preferredSize(
        _ size: OptionalDimensions
    ) -> Self {
        var result = self
        result._preferredSize = size
        return result
    }
    
    /// Sets the preferred size of the image using CGSize.
    public func _preferredSize(
        _ size: CGSize?
    ) -> Self {
        self._preferredSize(OptionalDimensions(size))
    }
}

extension _AnyImage {
    /// Converts the _AnyImage to a SwiftUI Image.
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
    
    /// Returns the AppKit or UIKit representation of the image.
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
    /// Returns the JPEG data representation of the image.
    public var jpegData: Data? {
        return appKitOrUIKitImage?._SwiftUIX_jpegData
    }
    
    /// Returns the PNG data representation of the image.
    public var pngData: Data? {
        return appKitOrUIKitImage?.data(using: .png)
    }
    
    /// Initializes an _AnyImage from JPEG data.
    public init?(jpegData: Data) {
        self.init(AppKitOrUIKitImage(_SwiftUIX_jpegData: jpegData))
    }
    
    public init?(data: Data) {
        self.init(AppKitOrUIKitImage(data: data))
    }
    
    /// Initializes an _AnyImage with the given url.
    public init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        self.init(data: data)
    }
}

// MARK: - Initializers

extension _AnyImage {
    /// Initializes an _AnyImage from an optional AppKit or UIKit image.
    public init?(_ image: AppKitOrUIKitImage?) {
        guard let image else {
            return nil
        }
        
        self.init(payload: .appKitOrUIKitImage(image))
    }
    
    /// Initializes an _AnyImage from an AppKit or UIKit image.
    public init(_ image: AppKitOrUIKitImage) {
        self.init(payload: .appKitOrUIKitImage(image))
    }
    
    /// Initializes an _AnyImage with a system image name.
    public init(systemName: String) {
        self.init(payload: .named(.system(systemName)))
    }
    
    /// Initializes an _AnyImage with an SF Symbol name.
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
            do {
                self = try Self(jpegData: try Data(from: decoder)).unwrap()
            } catch {
                throw _DecodingError.unsupported
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch payload {
            case .named(let name):
                try name.encode(to: encoder)
            case .appKitOrUIKitImage(let image):
                try image._SwiftUIX_jpegData.unwrap().encode(to: encoder)
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
    /// The content and behavior of the view.
    public var body: some View {
        _SwiftUI_image
    }
}

// MARK: - Auxiliary

extension _AnyImage {
    public enum FileType: String, Codable, Hashable, Sendable {
        case tiff
        case bmp
        case gif
        case jpeg
        case png
        case jpeg2000
    }
}

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitImage {
    /// Initializes an AppKitOrUIKitImage with the given _AnyImage.Name.
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
    /// Initializes an AppKitOrUIKitImage with the given _AnyImage.Name.
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
    /// Initializes an Image with the given _AnyImage.Name.
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
    
    /// Initializes an Image with the given _AnyImage.
    public init(_ image: _AnyImage) {
        switch image.payload {
            case .appKitOrUIKitImage(let image):
                self.init(image: image)
            case .named(let name):
                self.init(name)
        }
    }
    
    /// Initializes an Image with the given _AnyImage.
    @_disfavoredOverload
    public init(image: _AnyImage) {
        self.init(image)
    }
}
