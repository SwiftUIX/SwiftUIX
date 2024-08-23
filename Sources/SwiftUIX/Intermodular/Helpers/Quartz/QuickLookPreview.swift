//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Quartz
import SwiftUI

@_documentation(visibility: internal)
public class QuickLookPreviewItem: NSObject, QLPreviewItem {
    public var previewItemURL: URL?
    public var previewItemTitle: String?
    
    public init(url: URL, title: String) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

@_documentation(visibility: internal)
public struct QuickLookPreview: NSViewRepresentable {
    public typealias NSViewType = QLPreviewView
    
    public let url: URL?
    
    public init(url: URL?) {
        self.url = url
    }
    
    public func makeNSView(
        context: Context
    ) -> NSViewType {
        let nsView = QLPreviewView()
        
        nsView.autostarts = true
        
        return nsView
    }
    
    public func updateNSView(
        _ nsView: NSViewType,
        context: Context
    ) {
        nsView.previewItem = url.map({ $0 as QLPreviewItem })
        nsView.refreshPreviewItem()
    }
}

extension QuickLookPreview {
    public init(
        item: QuickLookPreviewItem
    ) {
        self.init(url: item.previewItemURL)
    }
}

#endif
