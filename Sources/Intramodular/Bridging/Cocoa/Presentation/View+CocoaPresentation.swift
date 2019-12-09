//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct CocoaPresentationIsPresented<Sheet: View>: ViewModifier {
    @Binding var isPresented: Bool
    
    let onDismiss: (() -> Void)?
    let content: () -> Sheet
    let presentationStyle: ModalViewPresentationStyle
    
    func sheet() -> CocoaPresentation {
        .init(
            content: { AnyView(self.content()) },
            onDismiss: onDismiss,
            shouldDismiss: { !self.isPresented },
            resetBinding: { self.isPresented = false },
            presentationStyle: presentationStyle
        )
    }
    
    func body(content: Content) -> some View {
        content.background(
            EmptyView()
                .preference(
                    key: CocoaPresentationPreferenceKey.self,
                    value: isPresented ? sheet() : nil
            )
        )
    }
}

private struct CocoaPresentationItem<Item: Identifiable, Sheet: View>: ViewModifier  {
    @Binding var item: Item?
    
    let onDismiss: (() -> Void)?
    let presentationStyle: ModalViewPresentationStyle
    let content: (Item) -> Sheet
    
    func sheet(for item: Item) -> CocoaPresentation {
        CocoaPresentation(
            content: { AnyView(self.content(item)) },
            onDismiss: onDismiss,
            shouldDismiss: { self.item?.id != item.id },
            resetBinding: { self.item = nil },
            presentationStyle: presentationStyle
        )
    }
    
    func body(content: Content) -> some View {
        content.backgroundPreference(
            key: CocoaPresentationPreferenceKey.self,
            value: self.item != nil ? self.sheet(for: self.item!) : nil
        )
    }
}

extension View {
    public func cocoaPresentation<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        presentationStyle: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            CocoaPresentationIsPresented(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content,
                presentationStyle: presentationStyle
            )
        )
    }
    
    public func cocoaPresentation<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        presentationStyle: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        modifier(
            CocoaPresentationItem(
                item: item,
                onDismiss: onDismiss,
                presentationStyle: presentationStyle,
                content: content
            )
        )
    }
}

#endif
