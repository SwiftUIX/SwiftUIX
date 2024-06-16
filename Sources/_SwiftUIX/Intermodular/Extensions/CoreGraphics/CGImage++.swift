//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
#if canImport(CoreVideo)
import CoreVideo
#endif
import Swift

extension CGImage {
    public var size: CGSize {
        CGSize(width: width, height: height)
    }
}

#if canImport(CoreVideo)
extension CGImage {
    public func _SwiftUIX_toPixelBuffer() -> CVPixelBuffer? {
        let imageWidth: Int = Int(width)
        let imageHeight: Int = Int(height)
        let attributes: [NSObject:AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA) as CFNumber,
            kCVPixelBufferCGImageCompatibilityKey: true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true as AnyObject,
            kCVPixelBufferMetalCompatibilityKey: true as AnyObject,
        ]
        
        var pixelBuffer: CVPixelBuffer? = nil
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            imageWidth,
            imageHeight,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary?,
            &pixelBuffer
        )
        
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
            return nil
        }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: imageWidth,
            height: imageHeight,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )

        if let context = context {
            context.draw(self, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
        } else {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, flags);
           
            return nil
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, flags);
        
        return pixelBuffer
    }
}
#endif
