//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct CocoaPresentationCoordinatorAttacher: ViewModifier {
    let coordinator: CocoaPresentationCoordinator
    
    func body(content: Content) -> some View {
        content
            .environment(\.dynamicViewPresenter, coordinator)
            .onPreferenceChange(CocoaPresentationPreferenceKey.self) { presentation in
                if let presentation = presentation {
                    self.coordinator.present(presentation)
                } else {
                    self.coordinator.dismiss()
                }
            }
            .onPreferenceChange(AnyModalPresentation.DidAttemptToDismissKey.self) { value in
                self.coordinator.onDidAttemptToDismiss = value
            }
            .onPreferenceChange(AnyModalPresentation.IsActivePreferenceKey.self) { value in
                self.coordinator.viewController?.isModalInPresentation = value ?? false
            }
            .preference(key: CocoaPresentationPreferenceKey.self, value: nil)
            .preference(key: AnyModalPresentation.IsActivePreferenceKey.self, value: nil)
    }
}

final class CocoaPresentationPreferenceKey: TakeLastPreferenceKey<AnyModalPresentation> {
    
}

private struct CocoaPresentationIsPresented<Sheet: View>: ViewModifier {
    @Environment(\.self) var environment
    
    @Binding var isPresented: Bool
    
    let content: () -> Sheet
    let contentName: ViewName?
    let shouldDismiss: (() -> Bool)?
    let onDismiss: () -> Void
    let presentationStyle: ModalViewPresentationStyle
    
    func sheet() -> AnyModalPresentation {
        .init(
            content: { self.content() },
            contentName: contentName,
            shouldDismiss: shouldDismiss ?? { true },
            onDismiss: onDismiss,
            resetBinding: { self.isPresented = false },
            presentationStyle: presentationStyle,
            environmentBuilder: .init()
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
    
    let onDismiss: () -> Void
    let presentationStyle: ModalViewPresentationStyle
    let content: (Item) -> Sheet
    let contentName: (Item) -> ViewName?
    
    func presentation(for item: Item) -> AnyModalPresentation {
        AnyModalPresentation(
            content: { self.content(item) },
            contentName: self.contentName(item),
            shouldDismiss: { self.item?.id != item.id },
            onDismiss: onDismiss,
            resetBinding: { self.item = nil },
            presentationStyle: presentationStyle,
            environmentBuilder: .init()
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
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            CocoaPresentationIsPresented(
                isPresented: isPresented,
                content: content,
                contentName: contentName,
                shouldDismiss: nil,
                onDismiss: onDismiss,
                presentationStyle: presentationStyle
            )
        )
    }
    
    public func cocoaPresentation<Item, Content>(
        named contentName: @escaping (Item) -> ViewName? = { _ in nil },
        item: Binding<Item?>,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalViewPresentationStyle,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View where Item: Identifiable, Content: View {
        modifier(
            CocoaPresentationItem(
                item: item,
                onDismiss: onDismiss,
                presentationStyle: presentationStyle,
                content: content,
                contentName: contentName
            )
        )
    }
}

#endif
