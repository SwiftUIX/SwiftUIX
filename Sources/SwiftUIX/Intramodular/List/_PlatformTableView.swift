//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

final class _PlatformTableView<Configuration: _CocoaListConfigurationType>: NSTableView {
    let listRepresentable: _CocoaList<Configuration>.Coordinator
        
    override var intrinsicContentSize: NSSize {
        CGSize(width: AppKitOrUIKitView.noIntrinsicMetric, height: AppKitOrUIKitView.noIntrinsicMetric)
    }
        
    override var translatesAutoresizingMaskIntoConstraints: Bool {
        get {
            super.translatesAutoresizingMaskIntoConstraints
        } set {
            if super.translatesAutoresizingMaskIntoConstraints != newValue {
                super.translatesAutoresizingMaskIntoConstraints = newValue
            }
        }
    }
    
    override var needsUpdateConstraints: Bool {
        get {
            super.needsUpdateConstraints
        } set {
            if newValue {
                _ = newValue // ignore
            }
        }
    }
    
    override var effectiveRowSizeStyle: RowSizeStyle {
        .custom
    }

    init(listRepresentable: _CocoaList<Configuration>.Coordinator) {
        UserDefaults.standard.set(false, forKey: "NSTableViewCanEstimateRowHeights")
        
        self.listRepresentable = listRepresentable
        
        super.init(frame: .zero)
        
        self.isHorizontalContentSizeConstraintActive = false
        self.isVerticalContentSizeConstraintActive = false
        
        self.allowsTypeSelect = false
        self.autoresizesSubviews = false
        self.backgroundColor = .clear
        self.cornerView = nil
        self.rowSizeStyle = .custom
        self.headerView = nil
        self.intercellSpacing = .zero
        self.selectionHighlightStyle = .none
        self.style = .plain
        self.usesAutomaticRowHeights = true
        self.wantsLayer = true
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resizeSubviews(
        withOldSize oldSize: NSSize
    ) {
        if frame.width != oldSize.width {
            self.listRepresentable.cache.invalidateSize()
        }
                
        super.resizeSubviews(withOldSize: oldSize)
    }
    
    override func viewDidChangeBackingProperties() {
        
    }

    override func invalidateIntrinsicContentSize() {
        
    }
    
    override func prepareContent(in rect: NSRect) {
        listRepresentable.stateFlags.insert(.isNSTableViewPreparingContent)
        
        defer {
            listRepresentable.stateFlags.remove(.isNSTableViewPreparingContent)
        }
        
        super.prepareContent(in: visibleRect)
    }
            
    override func noteHeightOfRows(
        withIndexesChanged indexSet: IndexSet
    ) {
        super.noteHeightOfRows(withIndexesChanged: indexSet)
    }
    
    override func updateConstraintsForSubtreeIfNeeded() {
        guard !listRepresentable.stateFlags.contains(.isNSTableViewPreparingContent) else {
            return
        }
        
        super.updateConstraintsForSubtreeIfNeeded()
    }
}

#endif
