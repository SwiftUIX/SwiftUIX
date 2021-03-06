//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Quartz
import SwiftUI

public struct QuickLookPreview: NSViewRepresentable {
    public typealias NSViewType = QLPreviewView
    
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = QLPreviewView()
        
        nsView.autostarts = true
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.previewItem = url as QLPreviewItem
    }
}

#endif
