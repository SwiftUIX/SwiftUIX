//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension Image {
    public init(systemName: SFSymbolName) {
        self.init(_systemName: systemName.rawValue)
    }
    
    public init(_systemName systemName: String) {
        #if os(macOS)
        if #available(OSX 11.0, *) {
            self.init(systemName: systemName)
        } else {
            fatalError("unimplemented")
        }
        #else
        self.init(systemName: systemName)
        #endif
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
@_spi(Internal)
extension UIImage {
    public convenience init?(
        _SwiftUIX_systemName systemName: String
    ) {
        self.init(systemName: systemName)
    }
    
    public convenience init?(
        _SwiftUIX_systemName systemName: String,
        withConfiguration configuration: SymbolConfiguration
    ) {
        self.init(systemName: systemName, withConfiguration: configuration)
    }
}
#elseif os(macOS)
@_spi(Internal)
extension AppKitOrUIKitImage {
    public convenience init?(
        _SwiftUIX_systemName systemName: String
    ) {
        if #available(macOS 11.0, *) {
            self.init(
                systemSymbolName: systemName,
                accessibilityDescription: nil
            )
        } else {
            return nil
        }
    }
    
    public enum ImageRenderingMode {
        case alwaysOriginal
    }
    
    public func withTintColor(
        _ color: NSColor,
        renderingMode: NSImage.ImageRenderingMode
    ) -> NSImage {
        if !isTemplate {
            return self
        }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)
        
        image.unlockFocus()
        image.isTemplate = false
        
        return image
    }
}

public protocol _NSImageType {
    
}

extension NSImage: _NSImageType {
    
}

extension _NSImageType where Self: NSImage {
    @available(macOS 11.0, *)
    public init?(
        _SwiftUIX_systemName systemName: String,
        withConfiguration configuration: SymbolConfiguration
    ) {
        self = NSImage(_SwiftUIX_systemName: systemName)?.withSymbolConfiguration(configuration) as! Self
    }
}
#endif
