//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Image {
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

#if os(macOS)

extension Image {
    @available(*, deprecated, message: "This function is currently unavailable on macOS.")
    public init(systemName: String) {
        fatalError() // FIXME(@vmanot)
    }
}

#endif
