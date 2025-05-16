//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@_documentation(visibility: internal)
public class _AnyCocoaMenuBarExtraCoordinator: Identifiable, ObservableObject {
    private static var allCases: [_AnyCocoaMenuBarExtraCoordinator] = [] // FIXME: Practically doesn't matter given that `Scene` result builders can't accomodate conditionals for `_CocoaMenuBarExtra` to be potentially removed but technically should be weak
    
    public var id: AnyHashable {
        fatalError()
    }
    
    fileprivate init() {
        _AnyCocoaMenuBarExtraCoordinator.allCases.append(self)
    }
    
    func _update() {
        
    }
    
    static func _updateAll() {
        allCases.forEach({
            $0._update()
        })
    }
}

@_documentation(visibility: internal)
public class _CocoaMenuBarExtraCoordinator<ID: Hashable, Label: View, Content: View>: _AnyCocoaMenuBarExtraCoordinator {
    private let cocoaStatusBar = NSStatusBar.system
    
    var cocoaStatusItem: NSStatusItem?
    
    public var item: MenuBarItem<ID, Label, Content>
    public var action: (@MainActor () -> Void)?
    
    package private(set) var makePopover: (() -> _AppKitMenuBarExtraPopover<ID, Label, Content>)?
    package private(set) var popover: _AppKitMenuBarExtraPopover<ID, Label, Content>? = nil
    
    public var wantsPopover: Bool {
        guard Content.self != EmptyView.self else {
            return false
        }
        
        guard makePopover != nil else {
            return false
        }
        
        return true
    }
    
    public override var id: AnyHashable {
        item.id
    }
    
    public init(
        item: MenuBarItem<ID, Label, Content>,
        action: (@MainActor () -> Void)?
    ) {
        self.item = item
        self.action = action
        
        super.init()
        
        Task.detached {
            Task(priority: .userInitiated) { @MainActor in
                while !NSApplication.shared.isRunning {
                    try await Task._SwiftUIX_sleep(seconds: 0.1)
                }
                
                self._setUp()
            }
        }
    }
    
    private func _setUp() {
        guard self.cocoaStatusItem == nil else {
            return
        }
        
        assert(NSApplication.shared.isRunning)
        
        let item = self.cocoaStatusBar.statusItem(
            withLength: item.length ?? NSStatusItem.variableLength
        )
        
        if let button = item.button {
            button.action = #selector(self.didActivate)
            button.target = self
        }
        
        self.cocoaStatusItem = item
        
        if wantsPopover {
            self.popover = self.makePopover?()
        }
        
        self._update()
    }
    
    override func _update() {
        guard let statusItem: NSStatusItem = cocoaStatusItem else {
            return
        }
        
        statusItem.update(from: item, coordinator: self)
    }
    
    @objc private func didActivate(
        _ sender: AnyObject?
    ) {
        DispatchQueue.asyncOnMainIfNecessary {
            self.action?()
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
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        let item = MenuBarItem<ID, Label, Content>(
            id: id,
            length: nil,
            action: action,
            label: label,
            content: content
        )
        
        let popover: _SwiftUIX_ObservableReferenceBox<_AppKitMenuBarExtraPopover<ID, Label, Content>?> = .init(wrappedValue: nil)
        
        self.init(
            item: item,
            action: {
                action?()
                
                popover.wrappedValue?.toggle()
            }
        )
        
        self.makePopover = {
            assert(popover.wrappedValue == nil)
            
            let result = _AppKitMenuBarExtraPopover(coordinator: self)
            
            popover.wrappedValue = result
            
            return result
        }
    }
    
    public convenience init(
        id: ID,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.init(
            id: id,
            action: nil,
            content: content,
            label: label
        )
    }
    
    public convenience init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) where ID == AnyHashable {
        self.init(
            id: UUID().uuidString,
            content: content,
            label: label
        )
    }
    
    public convenience init(
        action: (@MainActor () -> Void)?,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
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
        @ViewBuilder content: @escaping () -> Content
    ) where ID == AnyHashable, Label == Image {
        self.init(id: UUID().uuidString, content: content) {
            Image(systemName: systemImage)
        }
    }
}

// MARK: - Supplementary

@_documentation(visibility: internal)
public struct _CocoaMenuBarExtra<Label: View, Content: View>: DynamicProperty, Scene {
    @TimerState(interval: 0.01, maxCount: 1) var tick: Int
    
    private let label: Label
    private let content: Content

    @StateObject private var base: _AnyCocoaMenuBarExtraCoordinator
        
    public init(
        action: @MainActor @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label()
        self.content = content()

        _base = .init(wrappedValue: _CocoaMenuBarExtraCoordinator(
            action: action,
            label: label,
            content: content
        ))
                
        _AnyCocoaMenuBarExtraCoordinator._updateAll()
    }

    public init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(action: { }, label: label, content: content)
    }

    public init(
        action: @MainActor @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) where Content == EmptyView {
        self.init(action: action, label: label, content: { EmptyView() })
    }

    @available(*, deprecated, message: "Use init(label:content) instead.")
    @_disfavoredOverload
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.init(label: label, content: content)
    }
        
    public init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) where Label == Text {
        self.init(label: { Text(titleKey) }, content: content)
    }
    
    public var body: some Scene {
        _EmptyScene().onChange(of: tick) { _ in
            _ = base
        }
        
        let _ = Task { @MainActor in
            if let base = base as? _CocoaMenuBarExtraCoordinator<AnyHashable, Label, Content> {
                base.item.label = { label }
                base.item.content = { content }

                base._update()
            } else {
                base._update()
            }
        }
    }
}

// MARK: - Auxiliary

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
