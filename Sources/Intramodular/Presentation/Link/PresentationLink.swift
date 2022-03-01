//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A control which presents content when triggered.
///
/// A revival of `PresentationLink` (from Xcode 11 beta 3).
public struct PresentationLink<Destination: View, Label: View>: PresentationLinkView {
    @Environment(\._environmentInsertions) private var environmentInsertions
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @Environment(\.cocoaPresentationContext) private var cocoaPresentationContext
    #endif
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.modalPresentationStyle) private var _environment_modalPresentationStyle
    @Environment(\.presenter) private var presenter
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom
    
    private let _destination: Destination
    private let _isPresented: Binding<Bool>?
    private let _onDismiss: () -> Void
    
    private var _presentationStyle: ModalPresentationStyle?
    
    private let label: Label
    private let action: () -> Void

    @State private var name: AnyHashable = UUID()
    @State private var id: AnyHashable = UUID()
    @State private var _internal_isPresented: Bool = false
    
    private var isPresented: Binding<Bool> {
        let base = (_isPresented ?? $_internal_isPresented)
        
        return Binding(
            get: {
                base.wrappedValue
            },
            set: { newValue in
                base.wrappedValue = newValue
            }
        )
    }
    
    private var presentationStyle: ModalPresentationStyle {
        _presentationStyle ?? _environment_modalPresentationStyle
    }
    
    private var presentation: AnyModalPresentation {
        func reset() {
            self.isPresented.wrappedValue = false
        }
        
        #if !os(watchOS)
        let content = AnyPresentationView(
            _destination
                .managedObjectContext(managedObjectContext)
        )
        .modalPresentationStyle(presentationStyle)
        .preferredSourceViewName(name)
        .environment(environmentInsertions)
        #else
        let content = AnyPresentationView(
            _destination
                .managedObjectContext(managedObjectContext)
        )
        .modalPresentationStyle(presentationStyle)
        .preferredSourceViewName(name)
        .environment(environmentInsertions)
        #endif
        
        return AnyModalPresentation(
            id: id,
            content: content,
            onDismiss: _onDismiss,
            reset: reset
        )
    }
    
    public var body: some View {
        PassthroughView {
            if let presenter = presenter, userInterfaceIdiom != .mac, presentationStyle != .automatic {
                customPresentationButton(presenter: presenter)
            } else if presentationStyle == .automatic {
                systemSheetPresentationButton
            } else if presentationStyle == .popover, userInterfaceIdiom == .pad || userInterfaceIdiom == .mac {
                systemPopoverPresentationButton
            } else {
                customPresentationButtonWithAdHocPresenter
            }
        }
        .background(
            ZeroSizeView()
                .id(isPresented.wrappedValue)
                .allowsHitTesting(false)
                .accessibility(hidden: true)
        )
        .name(name, id: id)
    }
    
    @ViewBuilder
    private func customPresentationButton(presenter: DynamicViewPresenter) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if case .popover(_, _) = presentationStyle {
            IntrinsicGeometryReader { proxy in
                if presenter is CocoaPresentationCoordinator {
                    Button(
                        action: togglePresentation,
                        label: label
                    )
                    .preference(
                        key: AnyModalPresentation.PreferenceKey.self,
                        value: .init(
                            presentationID: id,
                            presentation: isPresented.wrappedValue ?
                                presentation.popoverAttachmentAnchorBounds(proxy.frame(in: .global))
                                : nil
                        )
                    )
                    ._resolveAppKitOrUIKitViewControllerIfAvailable()
                } else {
                    Button(
                        action: togglePresentation,
                        label: label
                    )
                    .preference(
                        key: AnyModalPresentation.PreferenceKey.self,
                        value: .init(
                            presentationID: id,
                            presentation: isPresented.wrappedValue ?
                                presentation.popoverAttachmentAnchorBounds(proxy.frame(in: .global))
                                : nil
                        )
                    )
                }
            }
        } else {
            Button {
                presenter.presentOnTop(presentation)
                
                isPresented.wrappedValue = true
            } label: {
                label
            }
            .background {
                ZeroSizeView()
                    .id(isPresented.wrappedValue)
                    .preference(
                        key: AnyModalPresentation.PreferenceKey.self,
                        value: .init(
                            presentationID: id,
                            presentation: isPresented.wrappedValue
                            ? presentation
                            : nil
                        )
                    )
            }
        }
        #else
        Button {
            togglePresentation()
            
            presenter.present(presentation)
        } label: {
            label
        }
        #endif
    }
    
    @ViewBuilder
    private var systemPopoverPresentationButton: some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        Button(action: togglePresentation, label: label)
            .popover(isPresented: isPresented.onChange { newValue in
                if !newValue {
                    _onDismiss()
                }
            }) {
                presentation.content
            }
        #else
        systemSheetPresentationButton
        #endif
    }
    
    private var systemSheetPresentationButton: some View {
        Button(
            action: togglePresentation,
            label: label
        )
        .sheet(
            isPresented: isPresented,
            onDismiss: _onDismiss,
            content: { presentation.content }
        )
    }

    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    struct _AdHocPresenter: View {
        @Environment(\.cocoaPresentationCoordinatorBox) private var cocoaPresentationCoordinatorBox

        let id: AnyHashable
        let isPresented: Binding<Bool>
        let presentation: AnyModalPresentation

        var cocoaPresentationCoordinator: CocoaPresentationCoordinator? {
            cocoaPresentationCoordinatorBox.value
        }

        @ViewBuilder
        var body: some View {
            ZeroSizeView()
                .id(isPresented.wrappedValue)
                .preference(
                    key: AnyModalPresentation.PreferenceKey.self,
                    value: .init(
                        presentationID: id,
                        presentation: isPresented.wrappedValue
                        ? presentation
                        : nil
                    )
                )
                .background {
                    PerformAction { [weak cocoaPresentationCoordinator] in
                        guard
                            isPresented.wrappedValue,
                            let presentedCoordinator = cocoaPresentationCoordinator?.presentedCoordinator,
                            let activePresentation = presentedCoordinator.presentation
                        else {
                            return
                        }

                        if activePresentation.id == presentation.id {
                            presentedCoordinator.update(with: .init(presentationID: id, presentation: presentation))
                        }
                    }
                }
                .onChange(of: isPresented.wrappedValue) { [weak cocoaPresentationCoordinator] _ in
                    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
                    // Attempt to detect an invalid state where the coordinator has a presented coordinator, but no presentation.
                    guard
                        !isPresented.wrappedValue,
                        let presentedCoordinator = cocoaPresentationCoordinator?.presentedCoordinator,
                        let presentedViewController = presentedCoordinator.viewController,
                        presentedCoordinator.presentation == nil,
                        presentedViewController is CocoaPresentationHostingController
                    else {
                        return
                    }

                    // This whole on-change hack is needed because sometimes even though `isPresented.wrappedValue` changes to `false`, the preference key doesn't propagate up.
                    // Here we force the presentation coordinator to update.
                    presentedCoordinator.update(with: .init(presentationID: id, presentation: nil))
                    #endif
                }
        }
    }
    #endif

    @ViewBuilder
    private var customPresentationButtonWithAdHocPresenter: some View {
        #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
        Button(
            action: togglePresentation,
            label: label
        )
        .background {
            CocoaHostingView {
                _AdHocPresenter(
                    id: id,
                    isPresented: isPresented,
                    presentation: presentation
                )
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
        #else
        systemSheetPresentationButton
        #endif
    }
    
    private func togglePresentation() {
        action()
        
        isPresented.wrappedValue.toggle()
    }
}

// MARK: - API -

extension PresentationLink {
    public init(
        action: @escaping () -> Void,
        @ViewBuilder destination: () -> Destination,
        onDismiss: @escaping () -> () = { },
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination()
        self._onDismiss = onDismiss
        self._isPresented = nil
        
        self.label = label()
        self.action = action
    }

    public init(
        destination: Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss ?? { }
        self._isPresented = nil
        
        self.label = label()
        self.action = { }
    }
    
    public init(
        destination: Destination,
        onDismiss: @escaping () -> () = { },
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss
        self._isPresented = nil
        
        self.label = label()
        self.action = { }
    }
        
    public init(
        destination: Destination,
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> () = { },
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss
        self._isPresented = isPresented
        
        self.label = label()
        self.action = { }
    }
    
    public init(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> () = { },
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination()
        self._onDismiss = onDismiss
        self._isPresented = isPresented
        
        self.label = label()
        self.action = { }
    }
    
    public init(
        destination: Destination,
        isPresented: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = { }
        self._isPresented = isPresented
        
        self.label = label()
        self.action = { }
    }
    
    public init<V: Hashable>(
        destination: Destination,
        tag: V,
        selection: Binding<V?>,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = { selection.wrappedValue = nil }
        self._isPresented = .init(
            get: { selection.wrappedValue == tag },
            set: { newValue in
                if newValue {
                    selection.wrappedValue = tag
                } else {
                    selection.wrappedValue = nil
                }
            }
        )
        
        self.label = label()
        self.action = { }
    }
}

extension PresentationLink {
    public func presentationStyle(_ presentationStyle: ModalPresentationStyle) -> Self {
        then({ $0._presentationStyle = presentationStyle })
    }
}

extension View {
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(present destination: Destination) -> some View {
        modifier(_PresentOnPressViewModifier(destination: destination))
    }
    
    /// Adds a destination to present when this view is pressed.
    public func onPress<Destination: View>(
        present destination: Destination,
        isPresented: Binding<Bool>
    ) -> some View {
        PresentationLink(
            destination: destination,
            isPresented: isPresented,
            label: { self.contentShape(Rectangle()) }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Auxiliary Implementation -

struct _PresentOnPressViewModifier<Destination: View>: ViewModifier {
    @Environment(\.presenter) var presenter
    
    let destination: Destination
    
    init(destination: Destination) {
        self.destination = destination
    }
    
    func body(content: Content) -> some View {
        presenter.ifSome { presenter in
            Button(action: { presenter.present(self.destination) }) {
                content.contentShape(Rectangle())
            }
        }.else {
            PresentationLink(
                destination: destination,
                label: { content.contentShape(Rectangle()) }
            )
            .buttonStyle(PlainButtonStyle())
        }
    }
}
