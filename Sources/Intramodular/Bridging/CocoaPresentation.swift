//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaPresentation: Equatable, Identifiable {
    public let id = UUID()
    
    let content: () -> OpaqueView
    let shouldDismiss: () -> Bool
    let onDismiss: (() -> Void)?
    let resetBinding: () -> ()
    let style: ModalViewPresentationStyle
    let environment: EnvironmentValues?
    
    public init<V: View>(
        content: @escaping () -> V,
        shouldDismiss: @escaping () -> Bool,
        onDismiss: (() -> Void)?,
        resetBinding: @escaping () -> (),
        style: ModalViewPresentationStyle,
        environment: EnvironmentValues?
    ) {
        self.content = { .init(content()) }
        self.shouldDismiss = shouldDismiss
        self.onDismiss = onDismiss
        self.style = style
        self.resetBinding = resetBinding
        self.environment = environment
    }
    
    public static func == (lhs: CocoaPresentation, rhs: CocoaPresentation) -> Bool {
        return lhs.id == rhs.id
    }
}

extension CocoaPresentation {
    class DidAttemptToDismissCallback: Equatable {
        let action: () -> Void
        
        init(_ action: @escaping () -> Void) {
            self.action = action
        }
        
        static func == (lhs: DidAttemptToDismissCallback, rhs: DidAttemptToDismissCallback) -> Bool {
            return lhs === rhs
        }
    }
    
    final class DidAttemptToDismissCallbacksPreferenceKey: ArrayReducePreferenceKey<DidAttemptToDismissCallback> {
        
    }
}

extension CocoaPresentation {
    final class IsModalInPresentationPreferenceKey: TakeFirstPreferenceKey<Bool> {
        
    }
}

// MARK: - Auxiliary Implementation -

public extension View {
    func onCocoaPresentationDidAttemptToDismiss(perform action: @escaping () -> Void) -> some View {
        return preference(key: CocoaPresentation.DidAttemptToDismissCallbacksPreferenceKey.self, value: [.init(action)])
    }
}

public extension View {
    func cocoaPresentationIsModalInPresentation(_ value: Bool) -> some View {
        return preference(key: CocoaPresentation.IsModalInPresentationPreferenceKey.self, value: value)
    }
}

#endif
