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
    @Environment(\.environmentBuilder) var environmentBuilder
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.modalPresentationStyle) var modalPresentationStyle
    @Environment(\.presenter) var presenter
    @Environment(\.userInterfaceIdiom) var userInterfaceIdiom
    
    let _destination: Destination
    let _isPresented: Binding<Bool>?
    let _onDismiss: () -> Void
    
    var _presentationStyle: ModalPresentationStyle?
    
    let label: Label
    
    @State var name = ViewName()
    @State var id: AnyHashable = UUID()
    @State var _internal_isPresented: Bool = false
    
    var isPresented: Binding<Bool> {
        _isPresented ?? $_internal_isPresented
    }
    
    var presentation: AnyModalPresentation {
        let content = AnyPresentationView(
            _destination
                .managedObjectContext(managedObjectContext)
                .modifier(_ResolveAppKitOrUIKitViewController())
        )
        .modalPresentationStyle(_presentationStyle ?? modalPresentationStyle)
        .preferredSourceViewName(name)
        .mergeEnvironmentBuilder(environmentBuilder)
        
        return AnyModalPresentation(
            id: id,
            content: content,
            onDismiss: _onDismiss,
            reset: {
                self.id = UUID()
                self.isPresented.wrappedValue = false
            }
        )
    }
    
    public var body: some View {
        PassthroughView {
            if let presenter = presenter,
               userInterfaceIdiom != .mac,
               presentation.presentationStyle != .automatic
            {
                #if os(iOS) || targetEnvironment(macCatalyst)
                if case .popover(_, _) = presentation.presentationStyle {
                    IntrinsicGeometryReader { proxy in
                        if let presenter = presenter as? CocoaPresentationCoordinator {
                            Button(
                                action: { isPresented.wrappedValue.toggle() },
                                label: label
                            )
                            .preference(
                                key: AnyModalPresentation.PreferenceKey.self,
                                value: isPresented.wrappedValue ? presentation.popoverAttachmentAnchorBounds(proxy.frame(in: .global)) : nil
                            )
                            .modifier(_UseCocoaPresentationCoordinator(presentationCoordinatorBox: .init(presenter)))
                        } else {
                            Button(
                                action: { isPresented.wrappedValue.toggle() },
                                label: label
                            )
                            .preference(
                                key: AnyModalPresentation.PreferenceKey.self,
                                value: isPresented.wrappedValue ? presentation.popoverAttachmentAnchorBounds(proxy.frame(in: .global)) : nil
                            )
                        }
                    }
                } else {
                    Button(action: { presenter.present(presentation) }, label: label)
                }
                #else
                Button(action: { presenter.present(presentation) }, label: label)
                #endif
            } else if presentation.presentationStyle == .automatic {
                Button(
                    action: { isPresented.wrappedValue = true },
                    label: label
                )
                .sheet(
                    isPresented: isPresented,
                    onDismiss: _onDismiss,
                    content: { presentation.content }
                )
            } else {
                Button(
                    action: { isPresented.wrappedValue = true },
                    label: label
                )
                .background(
                    CocoaHostingView {
                        ZeroSizeView().preference(
                            key: AnyModalPresentation.PreferenceKey.self,
                            value: isPresented.wrappedValue ? presentation : nil
                        )
                    }
                )
            }
        }
        .name(name, id: id)
    }
}

// MARK: - API -

extension PresentationLink {
    public init(
        destination: Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss ?? { }
        self._isPresented = nil
        
        self.label = label()
    }
    
    public init(
        destination: Destination,
        onDismiss: @escaping () -> () = { },
        style: ModalPresentationStyle,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss
        self._isPresented = nil
        self._presentationStyle = style
        
        self.label = label()
    }
    
    public init(
        destination: Destination,
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> () = { },
        style: ModalPresentationStyle,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = onDismiss
        self._isPresented = isPresented
        self._presentationStyle = style
        
        self.label = label()
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
    }
    
    public init<V: Hashable>(
        destination: Destination,
        tag: V,
        selection: Binding<V?>,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self._onDismiss = { }
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
