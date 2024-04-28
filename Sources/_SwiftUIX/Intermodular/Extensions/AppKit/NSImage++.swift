//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSImage {
    @_spi(Internal)
    public var cgImage: CGImage? {
        var frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        return self.cgImage(forProposedRect: &frame, context: nil, hints: nil)
    }
    
    public var _SwiftUIX_cgImage: CGImage? {
        cgImage
    }

    @_disfavoredOverload
    public convenience init?(cgImage: CGImage) {
        let size = NSSize(
            width: cgImage.width,
            height: cgImage.height
        )
        
        self.init(cgImage: cgImage, size: size)
    }
}

extension NSImage {
    public enum Orientation: UInt32 {
        case up = 1
        case upMirrored = 2
        case down = 3
        case downMirrored = 4
        case left = 5
        case leftMirrored = 6
        case right = 7
        case rightMirrored = 8
    }
    
    public var imageOrientation: NSImage.Orientation {
        guard let tiffData = self.tiffRepresentation,
              let imageSource = CGImageSourceCreateWithData(tiffData as CFData, nil) else {
            return .up
        }
        
        let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
        let orientationValue = properties?[kCGImagePropertyOrientation] as? UInt32 ?? UInt32(CGImagePropertyOrientation.up.rawValue)
        
        return NSImage.Orientation(rawValue: orientationValue) ?? .up
    }
    
    public convenience init!(
        cgImage: CGImage,
        scale: CGFloat,
        orientation: NSImage.Orientation
    ) {
        var ciImage = CIImage(cgImage: cgImage)
        
        ciImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
        
        let context = CIContext(options: nil)
        
        guard let transformedCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        self.init(
            cgImage: transformedCGImage,
            size: NSSize(
                width: ciImage.extent.size.width / scale,
                height: ciImage.extent.size.height / scale
            )
        )
    }
}

extension NSImage {
    public var scale: CGFloat {
        guard let screen = NSScreen.main else {
            return 1.0 // Default scale if no screen information is available
        }
        
        let scaleFactor = screen.backingScaleFactor
        let bestRepresentation = self.bestRepresentation(for: NSRect(x: 0, y: 0, width: size.width, height: size.height), context: nil, hints: [.ctm: AffineTransform(scale: scaleFactor)])
        
        if let bitmapRepresentation = bestRepresentation as? NSBitmapImageRep {
            return scaleFactor / (CGFloat(bitmapRepresentation.pixelsWide) / size.width)
        } else {
            return scaleFactor
        }
    }
    
    public func draw(
        at position: NSPoint
    ) {
        self.draw(
            at: position,
            from: NSRect(x: 0, y: 0, width: self.size.width, height: self.size.height),
            operation: .copy,
            fraction: 1
        )
    }

    public func draw(
        at point: NSPoint,
        blendMode: NSCompositingOperation,
        alpha: CGFloat
    ) {
        let rect = NSRect(
            origin: point,
            size: self.size
        )
        
        self.draw(
            in: rect,
            from: NSRect.zero,
            operation: blendMode,
            fraction: alpha
        )
    }
}

#endif
