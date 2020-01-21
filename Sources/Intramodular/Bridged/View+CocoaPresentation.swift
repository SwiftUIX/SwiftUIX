//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

final class CocoaPresentationPreferenceKey: TakeLastPreferenceKey<CocoaPresentation> {
    
}

private struct CocoaPresentationIsPresented<Sheet: View>: ViewModifier {
    @Environment(\.self) var environment
    
    @Binding var isPresented: Bool
    
    let content: () -> Sheet
    let shouldDismiss: (() -> Bool)?
    let onDismiss: (() -> Void)?
    let style: ModalViewPresentationStyle
    
    func sheet() -> CocoaPresentation {
        .init(
            content: { self.content() },
            shouldDismiss: shouldDismiss ?? { true },
            onDismiss: onDismiss,
            resetBinding: { self.isPresented = false },
            style: style,
            environment: environment
        )
    }
    
    func body(content: Content) -> some View {
        content.background(
            EmptyView().preference(
                key: CocoaPresentationPreferenceKey.self,
                value: isPresented ? sheet() : nil
            )
        )
    }
}

private struct CocoaPresentationItem<Item: Identifiable, Sheet: View>: ViewModifier  {
    @Environment(\.self) var environment
    
    @Binding var item: Item?
    
    let onDismiss: (() -> Void)?
    let style: ModalViewPresentationStyle
    let content: (Item) -> Sheet
    
    func presentation(for item: Item) -> CocoaPresentation {
        CocoaPresentation(
            content: { AnyView(self.content(item)) },
            shouldDismiss: { self.item?.id != item.id },
            onDismiss: onDismiss,
            resetBinding: { self.item = nil },
            style: style,
            environment: environment
        )
    }
    
    func body(content: Content) -> some View {
        content.backgroundPreference(
            key: CocoaPresentationPreferenceKey.self,
            value: item != nil ? presentation(for: self.item!) : nil
        )
    }
}

extension View {
    public func cocoaPresentation<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            CocoaPresentationIsPresented(
                isPresented: isPresented,
                content: content,
                shouldDismiss: nil,
                onDismiss: onDismiss,
                style: style
            )
        )
    }
    
    public func cocoaPresentation<Item, Content>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        modifier(
            CocoaPresentationItem(
                item: item,
                onDismiss: onDismiss,
                style: style,
                content: content
            )
        )
    }
}

#endif
