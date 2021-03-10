//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct AnyModalPresentation: Identifiable {
    public typealias PreferenceKey = TakeLastPreferenceKey<AnyModalPresentation>
    
    public let id: UUID
    
    public private(set) var content: AnyPresentationView
    
    @usableFromInline
    let resetBinding: () -> ()
    
    @usableFromInline
    init(_ content: AnyPresentationView) {
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
        onPresent: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil,
        resetBinding: @escaping () -> () = { }
    ) {
        self.id = id
        self.content = AnyPresentationView(content)
        self.resetBinding = resetBinding
        
        if let presentationStyle = presentationStyle {
            self.content = self.content.modalPresentationStyle(presentationStyle)
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

// MARK: - Protocol Conformances -

extension AnyModalPresentation: Equatable {
    public static func == (lhs: AnyModalPresentation, rhs: AnyModalPresentation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API -

extension View {
    public func isModalInPresentation(_ value: Bool) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return onUIViewControllerResolution {
            $0.isModalInPresentation = value
        }
        .preference(key: IsModalInPresentation.self, value: value)
        #else
        return preference(key: IsModalInPresentation.self, value: value)
        #endif
    }
}

// MARK: - Auxiliary Implementation -

struct IsModalInPresentation: PreferenceKey {
    static let defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
