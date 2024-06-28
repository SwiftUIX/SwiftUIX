//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitImage {
    public var _SwiftUIX_cgImage: CGImage? {
        cgImage
    }
    
    public var _SwiftUIX_jpegData: Data? {
        guard let cgImage = _SwiftUIX_cgImage else {
            return nil
        }
        
        if cgImage.alphaInfo != .none {
            guard let colorSpace = self.cgImage?.colorSpace, let context = CGContext(
                data: nil,
                width: Int(self.size.width),
                height: Int(self.size.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            ) else {
                return nil
            }
            
            context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
            
            guard let imageWithoutAlpha = context.makeImage() else {
                return nil
            }
            
            let uiImageWithoutAlpha = UIImage(cgImage: imageWithoutAlpha)
            
            return uiImageWithoutAlpha.jpegData(compressionQuality: 1.0)
        }
        
        return self.jpegData(compressionQuality: 1.0)
    }
    
    public convenience init?(_SwiftUIX_jpegData jpegData: Data) {
        self.init(data: jpegData)
    }
}
#endif

#if canImport(CoreVideo)
import CoreVideo

extension AppKitOrUIKitImage {
    public func _SwiftUIX_toPixelBuffer() -> CVPixelBuffer? {
        _SwiftUIX_cgImage?._SwiftUIX_toPixelBuffer()
    }
}
#endif

#if os(macOS)
extension AppKitOrUIKitImage {
    public var _SwiftUIX_jpegData: Data? {
        guard let tiffRepresentation = self.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            print("Failed to get TIFF representation or create bitmap image")
            return nil
        }
        
        if bitmapImage.hasAlpha {
            guard
                let colorSpace = bitmapImage.colorSpace.cgColorSpace,
                let context = CGContext(
                    data: nil,
                    width: bitmapImage.pixelsWide,
                    height: bitmapImage.pixelsHigh,
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: colorSpace,
                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
                )
            else {
                debugPrint("Failed to create graphics context")
                
                return nil
            }
            
            guard let cgImage = bitmapImage.cgImage else {
                debugPrint("Failed to get CGImage from bitmap image")
                
                return nil
            }
            
            context.draw(cgImage, in: CGRect(origin: .zero, size: self.size))
            
            guard let imageWithoutAlpha = context.makeImage() else {
                debugPrint("Failed to create image without alpha")
                
                return nil
            }
            
            let bitmapRepWithoutAlpha = NSBitmapImageRep(cgImage: imageWithoutAlpha)
            
            return bitmapRepWithoutAlpha.representation(using: .jpeg, properties: [:])
        }
        
        return bitmapImage.representation(using: .jpeg, properties: [:])
    }
    
    public convenience init?(_SwiftUIX_jpegData jpegData: Data) {
        self.init(data: jpegData)
    }
}
#endif
