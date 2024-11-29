//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import QuickLookUI
import SwiftUI

private struct _QuickLookPreviewPanelPresenter: NSViewRepresentable {
    private var isPresented: Binding<Bool>
    private var items: () -> [QLPreviewItem] // URLs of the files to be previewed
    
    init(
        items: @escaping @autoclosure () -> [QLPreviewItem],
        isPresented: Binding<Bool>
    ) {
        self.isPresented = isPresented
        self.items = items
    }
    
    func makeNSView(
        context: Context
    ) -> NSViewType {
        let view = NSViewType()
        
        return view
    }
    
    func updateNSView(
        _ view: NSViewType,
        context: Context
    ) {
        view.coordinator = context.coordinator
        
        context.coordinator.items = items
        context.coordinator.isPresented = isPresented
        
        if isPresented.wrappedValue {
            if !context.coordinator.isPanelVisible {
                context.coordinator.show()
            }
        } else {
            context.coordinator.hide()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: isPresented)
    }
}

extension _QuickLookPreviewPanelPresenter {
    init(
        items: @escaping @autoclosure () -> [URL],
        isPresented: Binding<Bool>
    ) {
        self.init(items: items().map({ $0 as QLPreviewItem }), isPresented: isPresented)
    }
    
    init<T: QLPreviewItem>(
        item: T,
        isPresented: Binding<Bool>
    ) {
        self.init(items: [item], isPresented: isPresented)
    }
    
    init(
        url: URL,
        isPresented: Binding<Bool>
    ) {
        self.init(items: [url], isPresented: isPresented)
    }
}

extension _QuickLookPreviewPanelPresenter {
    class NSViewType: NSView {
        weak var coordinator: Coordinator?
        
        override func acceptsPreviewPanelControl(
            _ panel: QLPreviewPanel!
        ) -> Bool {
            coordinator?.isPresented.wrappedValue ?? false
        }
        
        override open func beginPreviewPanelControl(
            _ panel: QLPreviewPanel!
        ) {
            
        }
        
        override open func endPreviewPanelControl(
            _ panel: QLPreviewPanel!
        ) {
            coordinator?.hide()
        }
    }
    
    class Coordinator: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
        static let panelWillCloseNotification = Notification.Name(rawValue: "QuickLookPreviewPanelWillClose")
        
        fileprivate var items: (() -> [QLPreviewItem]) = { [] }
        fileprivate var isPresented: Binding<Bool>
        
        fileprivate var previewPanel: QLPreviewPanel?
        fileprivate var previewItems: [QLPreviewItem]?
        
        fileprivate var isPanelVisible: Bool {
            QLPreviewPanel.sharedPreviewPanelExists() && previewPanel?.isVisible == true
        }

        fileprivate init(isPresented: Binding<Bool>) {
            self.isPresented = isPresented
            
            super.init()
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(panelWillClose),
                name: QLPreviewPanel.willCloseNotification,
                object: nil
            )
        }
        
        fileprivate func show() {
            let panel = self.setupPreviewPanelIfNecessary()
            
            guard !isPanelVisible else {
                return
            }
            
            panel.makeKeyAndOrderFront(nil)
        }
        
        fileprivate func hide() {
            _tearDownPreviewPanel()
        }
        
        @discardableResult
        private func setupPreviewPanelIfNecessary() -> QLPreviewPanel {
            if let previewPanel {
                return previewPanel
            }
            
            self.previewItems = items()
            
            let panel = QLPreviewPanel.shared()!
            
            panel.delegate = self
            panel.updateController()
            panel.dataSource = self
            
            self.previewPanel = panel
            
            return panel
        }
        
        private func _tearDownPreviewPanel() {
            guard let previewPanel else {
                return
            }
            
            let isPresented = isPresented
            
            if isPresented.wrappedValue != false {
                DispatchQueue.main.async {
                    isPresented.wrappedValue = false
                }
            }
            
            if previewPanel.dataSource !== nil {
                previewPanel.dataSource = nil
            }
            
            if previewPanel.delegate !== nil {
                previewPanel.delegate = nil
            }
            
            self.previewPanel = nil
            self.previewItems = nil
        }
        
        func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
            previewItems?.count ?? 0
        }
        
        override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
            return true
        }
        
        override open func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
            self.previewPanel?.delegate = self
        }
        
        override open func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
            _tearDownPreviewPanel()
        }
        
        func previewPanel(
            _ panel: QLPreviewPanel!,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            previewItems![index] as QLPreviewItem
        }
        
        func previewPanel(
            _ panel: QLPreviewPanel!,
            handle event: NSEvent!
        ) -> Bool {
            if let event = event {
                if event._SwiftUIX_isEscapeCharacter {
                    _tearDownPreviewPanel()
                    
                    return true
                }
            }
            
            return false
        }
        
        @objc private func panelWillClose() {
            _tearDownPreviewPanel()
        }
        
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            _tearDownPreviewPanel()
            
            return true
        }
        
        func windowWillClose(_ notification: Notification) {
            _tearDownPreviewPanel()
        }
    }
}

// MARK: - Preview

extension View {
    public func quickLookPreview(
        isPresented: Binding<Bool>,
        item: @escaping @autoclosure () -> any QLPreviewItem
    ) -> some View {
        background {
            _QuickLookPreviewPanelPresenter(item: item(), isPresented: isPresented)
                .frameZeroClipped()
                .accessibilityHidden(true)
        }
    }
    
    public func quickLookPreview(
        isPresented: Binding<Bool>,
        item: @escaping @autoclosure () -> URL
    ) -> some View {
        quickLookPreview(isPresented: isPresented, item: item() as QLPreviewItem)
    }
    
    public func quickLookPreview<T: QLPreviewItem>(
        isPresented: Binding<Bool>,
        items: @escaping @autoclosure () -> [T]
    ) -> some View {
        background {
            _QuickLookPreviewPanelPresenter(items: items(), isPresented: isPresented)
                .frameZeroClipped()
                .accessibilityHidden(true)
        }
    }
}

#endif
