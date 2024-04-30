//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

#if os(iOS) || os(visionOS)
extension AppKitOrUIKitImage {
    public var _SwiftUIX_cgImage: CGImage? {
        cgImage
    }
}
#endif

extension AppKitOrUIKitImage {
    public func _SwiftUIX_resizeImage(
        targetSize: CGSize
    ) -> AppKitOrUIKitImage {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
#if os(macOS)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: rect)
        newImage.unlockFocus()
        return newImage
#elseif os(iOS)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
#endif
    }
}

extension AppKitOrUIKitImage {
    public func _SwiftUIX_getPixelGrid() -> [[Int]] {
        guard let cgImage: CGImage = self._SwiftUIX_cgImage else {
            fatalError()
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        
        guard
            let data = cgImage.dataProvider?.data,
            let bytes = CFDataGetBytePtr(data)
        else {
            fatalError()
        }
        
        var pixelMap = Array<[Int]>(
            repeating: Array(repeating: 0, count: height),
            count: width
        )
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = Int(bytes[offset])
                let g = Int(bytes[offset + 1])
                let b = Int(bytes[offset + 2])
                
                pixelMap[x][y] = (r + g + b) / 3
            }
        }
        
        return pixelMap
    }
}

#endif
