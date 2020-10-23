//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CustomNavigationView<Content: View>: View {
    @usableFromInline
    let content: Content
    
    @usableFromInline
    @State var isNavigationBarVisible: Bool? = nil
    
    @inlinable
    public var isNavigationBarHidden: Bool? {
        guard let isNavigationBarVisible = isNavigationBarVisible else {
            return nil
        }
        
        return !isNavigationBarVisible
    }
    
    public var body: some View {
        NavigationView {
            PresentationView {
                content
                    .onPreferenceChange(IsNavigationBarVisible.self, perform: {
                        self.isNavigationBarVisible = $0
                    })
                    .environment(\.isNavigationBarHidden, isNavigationBarHidden)
            }
        }
    }
    
    @inlinable
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

final class IsNavigationBarVisible: TakeLastPreferenceKey<Bool> {
    
}

// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    final class IsNavigationBarHidden: DefaultEnvironmentKey<Bool> {
        
    }
    
    public var isNavigationBarHidden: Bool? {
        get {
            self[IsNavigationBarHidden]
        } set {
            self[IsNavigationBarHidden] = newValue
        }
    }
}

#endif
