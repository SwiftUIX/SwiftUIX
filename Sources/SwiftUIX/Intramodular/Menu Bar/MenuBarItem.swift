//
// Copyright (c) Vatsal Manot
//

#if canImport(AppKit)
import AppKit
#endif

import Swift
import SwiftUI

public enum _MenuBarExtraLabelContent: Hashable, View {
    case image(_AnyImage, size: CGSize?)
    case text(String)
    
    public var body: some View {
        switch self {
            case .image(let image, let size):
                image
                    .frame(size)
            case .text(let text):
                Text(text)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .image(let image, let size):
                image.hash(into: &hasher)
                
                (size?.width)?.hash(into: &hasher)
                (size?.height)?.hash(into: &hasher)
            case .text(let string):
                string.hash(into: &hasher)
        }
    }
}

/// A model that represents an item which can be placed in the menu bar.
public struct MenuBarItem<ID, Label: View, Content: View> {
    public let id: ID
    
    fileprivate let length: CGFloat?
    
    public let label: Label
    public let content: Content
    
    public init(
        id: ID,
        length: CGFloat?,
        label: Label,
        content: Content
    ) {
        self.id = id
        self.length = length
        self.label = label
        self.content = content
    }
}

extension MenuBarItem where Label == _MenuBarExtraLabelContent {
    fileprivate init(
        id: ID,
        length: CGFloat?,
        label: _MenuBarExtraLabelContent,
        content: Content
    ) {
        self.id = id
        self.length = length
        self.label = label
        self.content = content
    }
    
    public init(
        id: ID,
        length: CGFloat? = nil,
        image: _AnyImage,
        imageSize: CGSize? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            length: length ?? 28.0,
            label: .image(image, size: imageSize ?? CGSize(width: 18.0, height: 18.0)),
            content: content()
        )
    }
    
    public init(
        id: ID,
        length: CGFloat? = nil,
        image: _AnyImage.Name,
        imageSize: CGSize? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            length: length,
            label: .image(.named(image), size: imageSize),
            content: content()
        )
    }
    
    public init(
        id: ID,
        length: CGFloat? = 28.0,
        text: String,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            length: length,
            label: .text(text),
            content: content()
        )
    }
}

extension MenuBarItem: Identifiable where ID: Hashable {
    
}

// MARK: - API

#if os(macOS)

extension View {
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<ID: Hashable, Content: View>(
        id: ID,
        image: _AnyImage.Name,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertMenuBarPopover(
                item: MenuBarItem(
                    id: id,
                    image: image,
                    content: content
                ),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
    
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<Content: View>(
        image: _AnyImage.Name,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let content = content()
        
        return withInlineState(initialValue: UUID()) { id in
            menuBarItem(id: id.wrappedValue, image: image, isActive: isActive, content: { content })
        }
    }
    
    /// Adds a menu bar item configured to present a popover when clicked.
    public func menuBarItem<ID: Hashable, Content: View>(
        id: ID,
        systemImage image: String,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        modifier(
            InsertMenuBarPopover(
                item: MenuBarItem(id: id, image: .system(image), content: content),
                isActive: isActive
            )
        )
        .background(EmptyView().id(isActive?.wrappedValue))
    }
}

#endif

// MARK: - Auxiliary

#if os(macOS)
public class _AnyCocoaMenuBarExtraCoordinator: ObservableObject {
    fileprivate init() {
        
    }
}

public class _CocoaMenuBarExtraCoordinator<ID: Equatable, Label: View, Content: View>: _AnyCocoaMenuBarExtraCoordinator {
    private let cocoaStatusBar = NSStatusBar.system
    
    var cocoaStatusItem: NSStatusItem?
    
    public var item: MenuBarItem<ID, Label, Content>
    public var action: () -> Void
    
    private var popover: _AppKitMenuBarExtraPopover<ID, Label, Content>? = nil
    
    public init(
        item: MenuBarItem<ID, Label, Content>,
        action: @escaping () -> Void
    ) {
        self.item = item
        self.action = action
        
        super.init()
        
        DispatchQueue.asyncOnMainIfNecessary {
            self.cocoaStatusItem = self.cocoaStatusBar.statusItem(
                withLength: item.length ?? NSStatusItem.variableLength
            )
            
            self.cocoaStatusItem?.button?.action = #selector(self.didActivate)
            self.cocoaStatusItem?.button?.target = self
            
            self.update()
        }
    }
    
    public convenience init(
        id: ID,
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
                popover.wrappedValue?.toggle()
            }
        )
        
        popover.wrappedValue = _AppKitMenuBarExtraPopover(coordinator: self)
        
    }
    
    private func update() {
        cocoaStatusItem?.update(from: item)
    }
    
    @objc private func didActivate(_ sender: AnyObject?) {
        action()
    }
    
    deinit {
        if let cocoaStatusItem {
            cocoaStatusBar.removeStatusItem(cocoaStatusItem)
        }
    }
}

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
        
        if let button = button {
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
}

struct InsertMenuBarPopover<ID: Equatable, Label: View, PopoverContent: View>: ViewModifier {
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
