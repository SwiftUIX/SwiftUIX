//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

private struct EditMenuPresenter: ViewModifier {
    @Binding var isVisible: Bool
    
    let attachmentAnchor: UnitPoint?
    let editMenuItems: () -> [EditMenuItem]
    
    func body(content: Content) -> some View {
        content
            .background {
                _BackgroundPresenterView(
                    isVisible: $isVisible,
                    attachmentAnchor: attachmentAnchor,
                    editMenuItems: editMenuItems
                )
                .allowsHitTesting(false)
                .accessibility(hidden: true)
            }
    }
    
    struct _BackgroundPresenterView: AppKitOrUIKitViewRepresentable {
        @Binding var isVisible: Bool
        
        let attachmentAnchor: UnitPoint?
        let editMenuItems: () -> [EditMenuItem]
        
        func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
            AppKitOrUIKitViewType()
        }
        
        func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
            view.isVisible = $isVisible
            view.attachmentAnchor = attachmentAnchor
            view.editMenuItems = editMenuItems
            
            if isVisible {
                view.showMenu(sender: nil)
            }
        }
    }
}

// MARK: - API

/// A struct representing an item in the edit menu.
@_documentation(visibility: internal)
public struct EditMenuItem {
    let title: String
    let action: Action
    
    /// Creates a new edit menu item with the given title and action.
    ///
    /// - Parameters:
    ///   - title: The title of the menu item.
    ///   - action: The action to perform when the menu item is selected.
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = .init(action)
    }
}

extension View {
    /// Adds an edit menu to the view.
    ///
    /// - Parameters:
    ///   - isVisible: A binding to a Boolean value that determines whether the edit menu is visible.
    ///   - content: A closure that returns an array of `EditMenuItem` representing the items in the edit menu.
    /// - Returns: A view with the edit menu added.
    ///
    /// Use this modifier to add an edit menu to a view. The edit menu is a context menu that appears when the user interacts with the view, providing options for actions such as copy, paste, etc.
    ///
    /// Example usage:
    /// ```
    /// Text("Hello, world!")
    ///     .editMenu(isVisible: $isEditMenuVisible) {
    ///         EditMenuItem("Copy") {
    ///             // Perform copy action
    ///         }
    ///         EditMenuItem("Paste") {
    ///             // Perform paste action
    ///         }
    ///     }
    /// ```
    public func editMenu(
        isVisible: Binding<Bool>,
        @_ArrayBuilder<EditMenuItem> content: @escaping () -> [EditMenuItem]
    ) -> some View {
        modifier(
            EditMenuPresenter(
                isVisible: isVisible,
                attachmentAnchor: nil,
                editMenuItems: content
            )
        )
    }
}

// MARK: - Auxiliary

extension EditMenuPresenter._BackgroundPresenterView {
    class AppKitOrUIKitViewType: UIView {
        var isVisible: Binding<Bool>?
        var attachmentAnchor: UnitPoint?
        var editMenuItems: () -> [EditMenuItem] = { [] }
        
        private var itemIndexToActionMap: [Int: Action]?
        
        override var canBecomeFirstResponder: Bool {
            true
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            NotificationCenter.default.addObserver(self, selector: #selector(didHideEditMenu), name: UIMenuController.didHideMenuNotification, object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        @objc func showMenu(sender _: AnyObject?) {
            becomeFirstResponder()
            
            itemIndexToActionMap = [:]
            
            let items = editMenuItems()
            
            UIMenuController.shared.menuItems = items.enumerated().map { [weak self] (index, item) in
                let selector = Selector("performActionForEditMenuItemAtIndex\(index.description)")
                
                self?.itemIndexToActionMap?[index] = item.action
                
                let item = UIMenuItem(
                    title: item.title,
                    action: selector
                )
                
                return item
            }
            
            UIMenuController.shared.showMenu(from: self, rect: frame)
        }
        
        @objc func didHideEditMenu(_ sender: AnyObject?) {
            if let isVisible = isVisible, isVisible.wrappedValue {
                DispatchQueue.main.async {
                    isVisible.wrappedValue = false
                }
                
                if isFirstResponder {
                    resignFirstResponder()
                }
            }
            
            UIMenuController.shared.menuItems = nil
        }
        
        override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
            NSStringFromSelector(action).hasPrefix("performActionForEditMenuItemAtIndex")
        }
        
        @objc func performActionForEditMenuItemAtIndex(_ index: Int) {
            itemIndexToActionMap?[index]?.perform()
        }
        
        @objc(performActionForEditMenuItemAtIndex0)
        private func performActionForEditMenuItemAtIndex0() {
            performActionForEditMenuItemAtIndex(0)
        }
        
        @objc(performActionForEditMenuItemAtIndex1)
        private func performActionForEditMenuItemAtIndex1() {
            performActionForEditMenuItemAtIndex(1)
        }
        
        @objc(performActionForEditMenuItemAtIndex2)
        private func performActionForEditMenuItemAtIndex2() {
            performActionForEditMenuItemAtIndex(2)
        }
        
        @objc(performActionForEditMenuItemAtIndex3)
        private func performActionForEditMenuItemAtIndex3() {
            performActionForEditMenuItemAtIndex(3)
        }
        
        @objc(performActionForEditMenuItemAtIndex4)
        private func performActionForEditMenuItemAtIndex4() {
            performActionForEditMenuItemAtIndex(4)
        }
        
        @objc(performActionForEditMenuItemAtIndex5)
        private func performActionForEditMenuItemAtIndex5() {
            performActionForEditMenuItemAtIndex(5)
        }
        
        @objc(performActionForEditMenuItemAtIndex6)
        private func performActionForEditMenuItemAtIndex6() {
            performActionForEditMenuItemAtIndex(6)
        }
    }
}

#endif
