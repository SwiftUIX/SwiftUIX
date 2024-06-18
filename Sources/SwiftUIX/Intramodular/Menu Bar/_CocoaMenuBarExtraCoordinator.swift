//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

public class _AnyCocoaMenuBarExtraCoordinator: Identifiable, ObservableObject {
    public var id: AnyHashable {
        fatalError()
    }
    
    fileprivate init() {
        
    }
}

public class _CocoaMenuBarExtraCoordinator<ID: Hashable, Label: View, Content: View>: _AnyCocoaMenuBarExtraCoordinator {
    private let cocoaStatusBar = NSStatusBar.system
    
    var cocoaStatusItem: NSStatusItem?
    
    public var item: MenuBarItem<ID, Label, Content>
    public var action: @MainActor () -> Void
    
    private var popover: _AppKitMenuBarExtraPopover<ID, Label, Content>? = nil
    
    public override var id: AnyHashable {
        item.id
    }
    
    public init(
        item: MenuBarItem<ID, Label, Content>,
        action: @MainActor @escaping () -> Void
    ) {
        self.item = item
        self.action = action
        
        super.init()
        
        DispatchQueue.asyncOnMainIfNecessary(true) {
            let item = self.cocoaStatusBar.statusItem(
                withLength: item.length ?? NSStatusItem.variableLength
            )
            
            if let button = item.button {
                button.action = #selector(self.didActivate)
                button.target = self
            }
            
            self.cocoaStatusItem = item
            
            self.update()
        }
    }
    
    private func update() {
        cocoaStatusItem?.update(from: item)
    }
    
    @MainActor(unsafe)
    @objc private func didActivate(
        _ sender: AnyObject?
    ) {
        DispatchQueue.asyncOnMainIfNecessary {
            self.action()
        }
    }
    
    deinit {
        if let cocoaStatusItem {
            cocoaStatusBar.removeStatusItem(cocoaStatusItem)
        }
    }
}

// MARK: - Initializers

extension _CocoaMenuBarExtraCoordinator {
    public convenience init(
        id: ID,
        action: (@MainActor () -> Void)?,
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        let item = MenuBarItem<ID, Label, Content>(
            id: id,
            length: nil,
            label: label(),
            content: content()
        )
        
        let popover: _SwiftUIX_ObservableReferenceBox<_AppKitMenuBarExtraPopover<ID, Label, Content>?> = .init(wrappedValue: nil)
        
        self.init(
            item: item,
            action: {
                action?()
                
                popover.wrappedValue?.toggle()
            }
        )
        
        popover.wrappedValue = _AppKitMenuBarExtraPopover(coordinator: self)
    }
    
    public convenience init(
        id: ID,
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            id: id,
            action: nil,
            content: content,
            label: label
        )
    }
    
    public convenience init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) where ID == AnyHashable {
        self.init(
            id: UUID().uuidString,
            content: content,
            label: label
        )
    }
    
    public convenience init(
        action: @MainActor @escaping () -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) where ID == AnyHashable {
        self.init(
            id: UUID().uuidString,
            action: action,
            content: content,
            label: label
        )
    }
    
    public convenience init(
        systemImage: SFSymbolName,
        @ViewBuilder content: () -> Content
    ) where ID == AnyHashable, Label == Image {
        self.init(id: UUID().uuidString, content: content) {
            Image(systemName: systemImage)
        }
    }
}

// MARK: - Auxiliary

extension NSStatusItem {
    private static var NSStatusItem_labelHostingView_objcAssociationKey: UInt = 0
    
    fileprivate var labelHostingView: NSHostingView<AnyView>? {
        get {
            if let result = objc_getAssociatedObject(self, &NSStatusItem.NSStatusItem_labelHostingView_objcAssociationKey) as? NSHostingView<AnyView> {
                return result
            }
            
            return nil
        } set {
            objc_setAssociatedObject(self, &NSStatusItem.NSStatusItem_labelHostingView_objcAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate func update<ID, Label, Content>(
        from item: MenuBarItem<ID, Label, Content>
    ) {
        self.length = item.length ?? NSStatusItem.variableLength
        
        guard let button = button else {
            return
        }
        
        if let label = item.label as? _MenuBarExtraLabelContent {
            switch label {
                case .image(let image, let imageSize):
                    button.image = image.appKitOrUIKitImage
                    button.image?.size = imageSize ?? .init(width: 18, height: 18)
                    button.image?.isTemplate = true
                case .text(let string):
                    button.title = string
            }
        } else {            
            for subview in button.subviews {
                if subview !== self.labelHostingView {
                    subview.removeFromSuperview()
                }
            }
            
            let _labelHostingViewRootView: AnyView = item.label
                .frame(minHeight: button.frame.height == 0 ? nil : button.frame.height)
                .fixedSize(horizontal: true, vertical: true)
                .controlSize(.small)
                .font(.title3)
                .imageScale(.medium)
                .padding(.horizontal, .extraSmall)
                .eraseToAnyView()
            
            let hostingView: NSHostingView<AnyView> = self.labelHostingView ?? {
                let result = NSHostingView(
                    rootView:_labelHostingViewRootView
                )
                
                if #available(macOS 13.0, *) {
                    result.sizingOptions = [.intrinsicContentSize]
                }
                
                self.labelHostingView = result
                
                button.addSubview(result)
                
                return result
            }()
            
            hostingView.rootView = _labelHostingViewRootView
            hostingView.invalidateIntrinsicContentSize()
            
            if !hostingView.intrinsicContentSize.isAreaZero {
                hostingView.frame.size = hostingView.intrinsicContentSize
                hostingView._SwiftUIX_setNeedsLayout()
                
                button.setFrameSize(hostingView.intrinsicContentSize)
                
                button._SwiftUIX_setNeedsLayout()
                button._SwiftUIX_layoutIfNeeded()
            }
        }
    }
}

struct InsertMenuBarPopover<ID: Hashable, Label: View, PopoverContent: View>: ViewModifier {
    let item: MenuBarItem<ID, Label, PopoverContent>
    let isActive: Binding<Bool>?
    
    @State private var popover: _AppKitMenuBarExtraPopover<ID, Label, PopoverContent>? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        content.background {
            PerformAction {
                if let popover = self.popover {
                    popover.item = self.item
                } else {
                    self.popover = _AppKitMenuBarExtraPopover(item: self.item)
                }
                
                popover?._isActiveBinding = isActive
            }
        }
    }
}

#endif
