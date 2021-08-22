//
// Copyright (c) Texts HQ
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI
import UIKit

private struct EditMenuPresenter: ViewModifier {
    @Binding var isPresented: Bool
    
    let attachmentAnchor: UnitPoint?
    let editMenuItems: () -> [EditMenuItem]
    
    func body(content: Content) -> some View {
        content.background {
            _BackgroundPresenterView(
                isPresented: $isPresented,
                attachmentAnchor: attachmentAnchor,
                editMenuItems: editMenuItems
            )
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
    
    struct _BackgroundPresenterView: AppKitOrUIKitViewRepresentable {
        @Binding var isPresented: Bool
        
        let attachmentAnchor: UnitPoint?
        let editMenuItems: () -> [EditMenuItem]
        
        func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
            AppKitOrUIKitViewType()
        }
        
        func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
            view.isPresented = $isPresented
            view.attachmentAnchor = attachmentAnchor
            view.editMenuItems = editMenuItems
            
            if isPresented {
                view.showMenu(sender: nil)
            }
        }
    }
}

// MARK: - API -

public struct EditMenuItem {
    let title: String
    let action: Action
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = .init(action)
    }
}

extension View {
    public func editMenu(
        isPresented: Binding<Bool>,
        @ArrayBuilder<EditMenuItem> content: @escaping () -> [EditMenuItem]
    ) -> some View {
        modifier(
            EditMenuPresenter(
                isPresented: isPresented,
                attachmentAnchor: nil,
                editMenuItems: content
            )
        )
    }
}

// MARK: - Auxiliary Implementation -

extension EditMenuPresenter._BackgroundPresenterView {
    class AppKitOrUIKitViewType: UIView {
        var isPresented: Binding<Bool>?
        var attachmentAnchor: UnitPoint?
        var editMenuItems: () -> [EditMenuItem] = { [] }
        
        private var menuController: UIMenuController? = nil
        private var itemTitleToActionMap: [String: Action]?
        
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
            if let menuController = menuController {
                guard !menuController.isMenuVisible else {
                    return
                }
            }
            
            becomeFirstResponder()
            
            itemTitleToActionMap = [:]
            
            let items = editMenuItems()
            let menuController = UIMenuController()
            
            menuController.menuItems = items.map { item in
                itemTitleToActionMap?[item.title] = item.action
                
                let item = UIMenuItem(
                    title: item.title,
                    action: #selector(performMenuItemAction)
                )
                
                return item
            }
            
            menuController.showMenu(from: self, rect: frame)
            
            self.menuController = menuController
        }
        
        @objc func didHideEditMenu(_ sender: AnyObject?) {
            if let isPresented = isPresented, isPresented.wrappedValue {
                DispatchQueue.main.async {
                    isPresented.wrappedValue = false
                }
                
                if isFirstResponder {
                    resignFirstResponder()
                }
            }
            
            menuController = nil
        }
        
        @objc func performMenuItemAction(_ sender: AnyObject?) {
            guard let sender = sender as? UIMenuItem else {
                return
            }
            
            itemTitleToActionMap?[sender.title]?.perform()
        }
        
        override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
            action == #selector(performMenuItemAction)
        }
    }
}

#endif
