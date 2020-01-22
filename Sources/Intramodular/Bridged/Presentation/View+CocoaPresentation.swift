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
    let contentName: ViewName?
    let shouldDismiss: (() -> Bool)?
    let onDismiss: (() -> Void)?
    let style: ModalViewPresentationStyle
    
    func sheet() -> CocoaPresentation {
        .init(
            content: { self.content() },
            contentName: contentName,
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
    let contentName: (Item) -> ViewName?
    
    func presentation(for item: Item) -> CocoaPresentation {
        CocoaPresentation(
            content: { self.content(item) },
            contentName: self.contentName(item),
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
        named contentName: ViewName? = nil,
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        style: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            CocoaPresentationIsPresented(
                isPresented: isPresented,
                content: content,
                contentName: contentName,
                shouldDismiss: nil,
                onDismiss: onDismiss,
                style: style
            )
        )
    }
    
    public func cocoaPresentation<Item, Content>(
        named contentName: @escaping (Item) -> ViewName? = { _ in nil },
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
                content: content,
                contentName: contentName
            )
        )
    }
}

#endif
