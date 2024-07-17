//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

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
    
    package func update<ID, Label, Content>(
        from item: MenuBarItem<ID, Label, Content>,
        coordinator: _CocoaMenuBarExtraCoordinator<ID, Label, Content>
    ) {
        self.length = item.length ?? NSStatusItem.variableLength
        
        guard let button = button else {
            return
        }
        
        if let label = item.label as? _MenuBarExtraLabelContent {
            switch label {
                case .image(let image):
                    button.image = image.appKitOrUIKitImage
                    button.image?.size = CGSize(image._preferredSize, default: CGSize(width: 18, height: 18))
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
            
            let _labelHostingViewRootView: AnyView = { () -> AnyView in
                Group {
                    item.label
                        .frame(minHeight: button.frame.height == 0 ? nil : button.frame.height)
                        .fixedSize(horizontal: true, vertical: true)
                        .controlSize(.small)
                        .font(.title3)
                        .imageScale(.medium)
                        .padding(.horizontal, .extraSmall)
                        .contentShape(Rectangle())
                }
                .eraseToAnyView()
            }()
            
            let hostingView: NSHostingView<AnyView> = self.labelHostingView ?? {
                let result = NSHostingView(
                    rootView:_labelHostingViewRootView
                )
                
                if #available(macOS 13.0, *) {
                    result.sizingOptions = [.minSize, .intrinsicContentSize]
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
            
            button.isEnabled = true
        }
    }
}

#endif
