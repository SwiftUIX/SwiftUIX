//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#endif
import Swift
import SwiftUI
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func _fixedSize(horizontal: Bool, vertical: Bool) -> Self {
        then {
            $0.textViewConfiguration._fixedSize = .init((horizontal, vertical))
        }
    }
}

@available(macOS 11.0, iOS 14.0, watchOS 8.0, tvOS 14.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func _customAppKitOrUIKitClass(
        _ type: AppKitOrUIKitTextView.Type
    ) -> Self {
        then({ $0.customAppKitOrUIKitClassConfiguration = .init(class: type) })
    }
    
    public func _customAppKitOrUIKitClass<T: AppKitOrUIKitTextView>(
        _ type: T.Type,
        update: @escaping _CustomAppKitOrUIKitClassConfiguration.UpdateOperation<T>
    ) -> Self {
        then({ $0.customAppKitOrUIKitClassConfiguration = .init(class: type, update: update) })
    }
    
    @_disfavoredOverload
    public func _customAppKitOrUIKitClass<T: AppKitOrUIKitTextView>(
        _ type: T.Type,
        update: @escaping (T) -> Void
    ) -> Self {
        _customAppKitOrUIKitClass(type) { view, _ in
            update(view)
        }
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func onDeleteBackward(perform action: @escaping () -> Void) -> Self {
        then({ $0.textViewConfiguration.onDeleteBackward = action })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
        then({ $0.textViewConfiguration.isInitialFirstResponder = isInitialFirstResponder })
    }
    
    public func focused(_ isFocused: Binding<Bool>) -> Self {
        then({ $0.textViewConfiguration.isFocused = isFocused })
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func autocapitalization(
        _ autocapitalization: UITextAutocapitalizationType
    ) -> Self {
        then({ $0.textViewConfiguration.autocapitalization = autocapitalization })
    }
}
#endif

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func automaticQuoteSubstitutionDisabled(
        _ disabled: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.automaticQuoteSubstitutionDisabled = disabled })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {    
    public func foregroundColor(
        _ foregroundColor: Color
    ) -> Self {
        then({ $0.textViewConfiguration.cocoaForegroundColor = foregroundColor.toAppKitOrUIKitColor() })
    }
    
    @_disfavoredOverload
    public func foregroundColor(
        _ foregroundColor: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.textViewConfiguration.cocoaForegroundColor = foregroundColor })
    }
    
    public func placeholderColor(
        _ foregroundColor: Color
    ) -> Self {
        then({ $0.textViewConfiguration.placeholderColor = foregroundColor.toAppKitOrUIKitColor() })
    }
    
    @_disfavoredOverload
    public func placeholderColor(
        _ placeholderColor: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.textViewConfiguration.placeholderColor = placeholderColor })
    }
    
    public func tint(
        _ tint: Color
    ) -> Self {
        then({ $0.textViewConfiguration.tintColor = tint.toAppKitOrUIKitColor() })
    }
    
    @_disfavoredOverload
    public func tint(
        _ tint: AppKitOrUIKitColor
    ) -> Self {
        then({ $0.textViewConfiguration.tintColor = tint })
    }
    
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func linkForegroundColor(
        _ linkForegroundColor: Color?
    ) -> Self {
        then({ $0.textViewConfiguration.linkForegroundColor = linkForegroundColor?.toAppKitOrUIKitColor() })
    }
#endif
    
    public func font(
        _ font: Font
    ) -> Self {
        then {
            do {
                $0.textViewConfiguration.cocoaFont = try font.toAppKitOrUIKitFont()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    @_disfavoredOverload
    public func font(
        _ font: AppKitOrUIKitFont?
    ) -> Self {
        then({ $0.textViewConfiguration.cocoaFont = font })
    }
    
    public func kerning(
        _ kerning: CGFloat
    ) -> Self {
        then({ $0.textViewConfiguration.kerning = kerning })
    }
    
    @_disfavoredOverload
    public func textContainerInset(
        _ textContainerInset: AppKitOrUIKitInsets
    ) -> Self {
        then({ $0.textViewConfiguration.textContainerInsets = textContainerInset._SwiftUI_edgeInsets })
    }
    
    public func textContainerInset(
        _ textContainerInset: EdgeInsets
    ) -> Self {
        then({ $0.textViewConfiguration.textContainerInsets = textContainerInset })
    }
    
#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func textContentType(
        _ textContentType: UITextContentType?
    ) -> Self {
        then({ $0.textViewConfiguration.textContentType = textContentType })
    }
#endif
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func editable(
        _ editable: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.isEditable = editable })
    }
    
    public func isSelectable(
        _ isSelectable: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.isSelectable = isSelectable })
    }
}

@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func dismissKeyboardOnReturn(
        _ dismissKeyboardOnReturn: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.dismissKeyboardOnReturn = dismissKeyboardOnReturn })
    }
    
    public func enablesReturnKeyAutomatically(
        _ enablesReturnKeyAutomatically: Bool
    ) -> Self {
        then({ $0.textViewConfiguration.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically })
    }
}

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 11.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension TextView {
    public func keyboardType(
        _ keyboardType: UIKeyboardType
    ) -> Self {
        then({ $0.textViewConfiguration.keyboardType = keyboardType })
    }
    
    public func returnKeyType(
        _ returnKeyType: UIReturnKeyType
    ) -> Self {
        then({ $0.textViewConfiguration.returnKeyType = returnKeyType })
    }
}
#endif

#endif
