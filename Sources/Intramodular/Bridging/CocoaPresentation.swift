//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct CocoaPresentation: Equatable, Identifiable {
    let id = UUID()
    let content: () -> AnyView
    let onDismiss: (() -> Void)?
    let shouldDismiss: () -> Bool
    let style: ModalViewPresentationStyle
    
    static func == (lhs: CocoaPresentation, rhs: CocoaPresentation) -> Bool {
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
