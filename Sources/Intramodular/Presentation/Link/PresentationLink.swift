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
    let onDismiss: (() -> ())?
    let _isPresented: Binding<Bool>?
    let label: Label
    
    @State var name = ViewName()
    @State var id = UUID()
    @State var _internal_isPresented: Bool = false
    
    var destination: some View {
        _destination
            .managedObjectContext(managedObjectContext)
            .mergeEnvironmentBuilder(environmentBuilder)
            .modalPresentationStyle(modalPresentationStyle)
    }
    
    var isPresented: Binding<Bool> {
        _isPresented ?? $_internal_isPresented
    }
    
    public var body: some View {
        Group {
            if let presenter = presenter, _isPresented == nil, userInterfaceIdiom != .mac {
                Button {
                    presenter.present(
                        AnyModalPresentation(
                            id: self.id,
                            content: self.destination,
                            preferredSourceViewName: name,
                            presentationStyle: self.modalPresentationStyle,
                            onDismiss: { self.onDismiss?() },
                            resetBinding: { self.isPresented.wrappedValue = false }
                        )
                    )
                } label: {
                    label
                }
            } else if modalPresentationStyle == .automatic {
                Button(action: { self.isPresented.wrappedValue = true }, label: label).sheet(
                    isPresented: isPresented,
                    onDismiss: { self.onDismiss?() },
                    content: { CocoaHostingView(mainView: self.destination) }
                )
            } else {
                Button(
                    action: { self.isPresented.wrappedValue = true },
                    label: label
                ).background(
                    CocoaHostingView {
                        _Presenter(
                            id: id,
                            name: name,
                            destination: destination,
                            isPresented: isPresented,
                            onDismiss: onDismiss
                        )
                        .mergeEnvironmentBuilder(environmentBuilder)
                        .modalPresentationStyle(modalPresentationStyle)
                    }
                )
            }
        }
        .name(name)
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
        self.onDismiss = onDismiss
        self._isPresented = nil
        self.label = label()
    }
    
    public init(
        destination: Destination,
        isPresented: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self._destination = destination
        self.onDismiss = nil
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
        self.onDismiss = nil
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

extension PresentationLink {
    struct _Presenter<Destination: View>: View {
        @Environment(\.environmentBuilder) var environmentBuilder
        @Environment(\.modalPresentationStyle) var modalPresentationStyle
        
        private let id: UUID
        private let name: ViewName
        private let destination: Destination
        private let isPresented: Binding<Bool>
        private let onDismiss: (() -> ())?
        
        init(
            id: UUID,
            name: ViewName,
            destination: Destination,
            isPresented: Binding<Bool>,
            onDismiss: (() -> ())?
        ) {
            self.id = id
            self.name = name
            self.destination = destination
            self.isPresented = isPresented
            self.onDismiss = onDismiss
        }
        
        var presentation: AnyModalPresentation? {
            guard isPresented.wrappedValue else {
                return nil
            }
            
            return AnyModalPresentation(
                id: id,
                content: destination,
                preferredSourceViewName: name,
                presentationStyle: modalPresentationStyle,
                onDismiss: { self.onDismiss?() },
                resetBinding: { self.isPresented.wrappedValue = false }
            )
        }
        
        var body: some View {
            Group {
                if modalPresentationStyle == .automatic {
                    ZeroSizeView().sheet(
                        isPresented: isPresented,
                        onDismiss: { self.onDismiss?() },
                        content: { self.destination }
                    )
                } else {
                    ZeroSizeView().preference(
                        key: AnyModalPresentation.PreferenceKey.self,
                        value: presentation
                    )
                }
            }
        }
    }
}
