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
}

#if os(macOS)

extension Image {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public init(systemName: String) {
        fatalError() // FIXME(@vmanot)
    }
}

#endif
