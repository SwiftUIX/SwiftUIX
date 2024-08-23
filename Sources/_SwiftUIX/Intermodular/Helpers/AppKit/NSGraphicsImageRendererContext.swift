//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@_documentation(visibility: internal)
public class NSGraphicsImageRendererFormat {
    public var scale: Double = 1
    
    public init() {}
}

@_documentation(visibility: internal)
public class NSGraphicsImageRendererContext {
    public let cgContext: CGContext
    
    public init(cgContext: CGContext) {
        self.cgContext = cgContext
    }
    
    public func fill(_ color: NSColor) {
        color.setFill()
    }
    
    public func fill(_ rect: CGRect) {
        cgContext.fill(rect)
    }
}

@_documentation(visibility: internal)
public class NSGraphicsImageRenderer {
    public let size: CGSize
    public let format: NSGraphicsImageRendererFormat
    
    public init(size: CGSize, format: NSGraphicsImageRendererFormat = .init()) {
        self.size = size
        self.format = format
    }

    public func image(
        _ action: (NSGraphicsImageRendererContext) -> Void
    ) -> NSImage {
        let scaleFactor = format.scale
        let bitmapSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(bitmapSize.width),
            pixelsHigh: Int(bitmapSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 32) else {
            fatalError("Failed to create NSBitmapImageRep")
        }
        
        NSGraphicsContext.saveGraphicsState()
        
        guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep) else {
            fatalError("Failed to create graphics context")
        }
        
        NSGraphicsContext.current = graphicsContext
        
        let context = NSGraphicsImageRendererContext(cgContext: graphicsContext.cgContext)
        action(context)
        
        NSGraphicsContext.restoreGraphicsState()
        
        let renderedImage = NSImage(size: NSSize(width: size.width, height: size.height))
        renderedImage.addRepresentation(bitmapRep)
        return renderedImage
    }
}

#endif
