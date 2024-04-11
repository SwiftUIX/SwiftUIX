//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Quartz
import SwiftUI

public struct QuickLookPreview: NSViewRepresentable {
    public typealias NSViewType = QLPreviewView
    
    public let url: URL?
    
    public init(url: URL?) {
        self.url = url
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let nsView = QLPreviewView()
        
        nsView.autostarts = true
        
        return nsView
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.previewItem = url.map({ $0 as QLPreviewItem })
        nsView.refreshPreviewItem()
    }
}

extension QuickLookPreview {
    public init(item: QuickLookPreviewItem) {
        self.init(url: item.previewItemURL)
    }
}

public class QuickLookPreviewItem: NSObject, QLPreviewItem {
    public var previewItemURL: URL?
    public var previewItemTitle: String?
    
    public init(url: URL, title: String) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}

// Define a struct that conforms to NSViewRepresentable
public struct _QuickLookPreviewPanelPresenter: NSViewRepresentable {
    public var urls: [URL] // URLs of the files to be previewed
    
    public init(urls: [URL]) {
        self.urls = urls
    }
    
    public init(url: URL) {
        self.init(urls: [url])
    }
    
    // Create the NSView that the QLPreviewPanel will attach to
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            context.coordinator.previewPanel?.makeKeyAndOrderFront(nil)
        }
        return view
    }
    
    // Update the NSView if needed (not used in this case)
    public func updateNSView(_ nsView: NSView, context: Context) {}
    
    // Define the coordinator that will act as the datasource and delegate for QLPreviewPanel
    public func makeCoordinator() -> Coordinator {
        Coordinator(urls: urls)
    }
    
    // Coordinator class to manage the QLPreviewPanel
    public class Coordinator: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
        public var urls: [URL]
        public var previewPanel: QLPreviewPanel!
        
        public init(urls: [URL]) {
            self.urls = urls
            super.init()
            self.setupPreviewPanel()
        }
        
        // Setup the QLPreviewPanel
        private func setupPreviewPanel() {
            let panel = QLPreviewPanel.shared()!
            panel.dataSource = self
            panel.delegate = self
            panel.makeKeyAndOrderFront(nil) // Show the panel
            self.previewPanel = panel
        }
        
        // QLPreviewPanelDataSource methods
        public func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
            return urls.count
        }
        
        public func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem {
            return urls[index] as QLPreviewItem
        }
        
        // Optionally, handle closing of the panel to perform cleanup
        public func previewPanelDidClose(_ panel: QLPreviewPanel!) {
            previewPanel.dataSource = nil
            previewPanel.delegate = nil
            previewPanel = nil
        }
    }
}

#endif
