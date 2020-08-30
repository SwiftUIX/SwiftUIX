//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public typealias PreferenceKey = TakeLastPreferenceKey<AnyModalPresentation>
    
    public let id: UUID
    
    public private(set) var content: EnvironmentalAnyView
    
    @usableFromInline
    let resetBinding: () -> ()
    
    @usableFromInline
    init(_ content: EnvironmentalAnyView) {
        self.id = UUID()
        self.content = content
        self.resetBinding = { }
    }
    
    @usableFromInline
    init<V: View>(
        id: UUID = UUID(),
        content: V,
        contentName: ViewName? = nil,
        presentationStyle: ModalPresentationStyle? = nil,
        isModalDismissable: (() -> Bool)? = nil,
        onPresent: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        resetBinding: @escaping () -> () = { }
    ) {
        self.id = id
        self.content = EnvironmentalAnyView(content)
        self.resetBinding = resetBinding
        
        if let presentationStyle = presentationStyle {
            self.content = self.content.modalPresentationStyle(presentationStyle)
        }
        
        if let isModalDismissable = isModalDismissable {
            self.content = self.content.isModalDismissable(isModalDismissable)
        }
        
        if let onPresent = onPresent {
            self.content = self.content.onPresent(perform: onPresent)
        }
        
        if let onDismiss = onDismiss {
            self.content = self.content.onDismiss(perform: onDismiss)
        }
        
        if let name = contentName {
            self.content = self.content.name(name)
        }
    }
}

extension AnyModalPresentation {
    public func mergeEnvironmentBuilder(_ builder: EnvironmentBuilder) -> Self {
        var result = self
        
        result.mergeEnvironmentBuilderInPlace(builder)
        
        return result
    }
    
    public mutating func mergeEnvironmentBuilderInPlace(_ builder: EnvironmentBuilder) {
        content.mergeEnvironmentBuilderInPlace(builder)
    }
}

// MARK: - Protocol Implementations -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func isModalInPresentation(_ value: Bool) -> some View {
        preference(key: IsModalInPresentation.self, value: value)
    }
}

// MARK: - Auxiliary Implementation -

@usableFromInline
struct IsModalInPresentation: PreferenceKey {
    @usableFromInline
    static let defaultValue: Bool = false
    
    @usableFromInline
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
