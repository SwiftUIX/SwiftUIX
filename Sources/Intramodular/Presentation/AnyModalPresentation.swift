//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public let id = UUID()
    
    let content: () -> EnvironmentalAnyView
    let contentName: ViewName?
    
    let completion: () -> ()
    let shouldDismiss: () -> Bool
    let onDismiss: () -> Void
    let resetBinding: () -> ()
    
    let animated: Bool
    let presentationStyle: ModalViewPresentationStyle
    let environmentBuilder: EnvironmentBuilder?
    
    init<V: View>(
        content: @escaping () -> V,
        contentName: ViewName?,
        completion: @escaping () -> () = { },
        shouldDismiss: @escaping () -> Bool,
        onDismiss: @escaping () -> Void,
        resetBinding: @escaping () -> (),
        animated: Bool = false,
        presentationStyle: ModalViewPresentationStyle,
        environmentBuilder: EnvironmentBuilder = .init()
    ) {
        self.content = { .init(content()) }
        self.contentName = contentName
        self.completion = completion
        self.shouldDismiss = shouldDismiss
        self.onDismiss = onDismiss
        self.animated = animated
        self.presentationStyle = presentationStyle
        self.resetBinding = resetBinding
        self.environmentBuilder = environmentBuilder
    }
}

// MARK: - Protocol Implementations -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Auxiliary Implementation -

extension AnyModalPresentation {
    class DidAttemptToDismissCallback: Equatable {
        let action: () -> Void
        
        init(_ action: @escaping () -> Void) {
            self.action = action
        }
        
        static func == (lhs: DidAttemptToDismissCallback, rhs: DidAttemptToDismissCallback) -> Bool {
            return lhs === rhs
        }
    }
    
    final class DidAttemptToDismissKey: ArrayReducePreferenceKey<DidAttemptToDismissCallback> {
        
    }
}

extension AnyModalPresentation {
    final class IsActivePreferenceKey: TakeFirstPreferenceKey<Bool> {
        
    }
}

public extension View {
    func onPresentationDidAttemptToDismiss(perform action: @escaping () -> Void) -> some View {
        return preference(key: AnyModalPresentation.DidAttemptToDismissKey.self, value: [.init(action)])
    }
}

public extension View {
    func presentationIsModalInPresentation(_ value: Bool) -> some View {
        return preference(key: AnyModalPresentation.IsActivePreferenceKey.self, value: value)
    }
}
