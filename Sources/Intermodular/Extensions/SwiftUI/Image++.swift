//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Image {
    public enum Encoding {
        case png
        case jpeg(compressionQuality: CGFloat)
    }
    
    public init(image: AppKitOrUIKitImage) {
        #if os(macOS)
        self.init(nsImage: image)
        #else
        self.init(uiImage: image)
        #endif
    }
    
    public init(cgImage: CGImage) {
        #if os(macOS)
        self.init(nsImage: NSImage(cgImage: cgImage, size: .zero))
        #else
        self.init(uiImage: UIImage(cgImage: cgImage))
        #endif
    }
    
    /// Initializes and returns the image with the specified data.
    public init?(data: Data) {
        #if os(macOS)
        let image = NSImage(data: data)
        #else
        let image = UIImage(data: data)
        #endif
        
        guard let _image = image else {
            return nil
        }
        
        #if os(macOS)
        self.init(nsImage: _image)
        #else
        self.init(uiImage: _image)
        #endif
    }
}

extension Image {
    public func resizable(_ resizable: Bool) -> some View {
        Group {
            if resizable {
                self.resizable()
            } else {
                self
            }
        }
    }
    
    public func sizeToFit(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height, alignment: alignment)
    }
    
    @_disfavoredOverload
    public func sizeToFit(
        _ size: CGSize? = nil,
        alignment: Alignment = .center
    ) -> some View {
        sizeToFit(width: size?.width, height: size?.height, alignment: alignment)
    }
    
    public func sizeToFitSquare(
        sideLength: CGFloat?,
        alignment: Alignment = .center
    ) -> some View {
        sizeToFit(width: sideLength, height: sideLength, alignment: alignment)
    }
}

#if os(macOS) && swift(<5.3)

extension Image {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public init(systemName: String) {
        fatalError() // FIXME(@vmanot)
    }
}

#endif
