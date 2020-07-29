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
    @usableFromInline
    let _destination: Destination
    @usableFromInline
    let onDismiss: (() -> ())?
    @usableFromInline
    let _isPresented: Binding<Bool>?
    @usableFromInline
    let label: Label
    
    @State var _internal_isPresented: Bool = false
    
    @usableFromInline
    @Environment(\.environmentBuilder) var environmentBuilder
    @usableFromInline
    @Environment(\.managedObjectContext) var managedObjectContext
    @usableFromInline
    @Environment(\.modalPresentationStyle) var modalPresentationStyle
    
    @usableFromInline
    var destination: some View {
        CocoaHostingView {
            _destination
                .managedObjectContext(managedObjectContext)
                .mergeEnvironmentBuilder(environmentBuilder)
                .modalPresentationStyle(modalPresentationStyle)
        }
    }
    
    @usableFromInline
    var isPresented: Binding<Bool> {
        _isPresented ?? $_internal_isPresented
    }
    
    public var body: some View {
        Group {
            if modalPresentationStyle == .automatic {
                Button(action: { self.isPresented.wrappedValue = true }, label: label).sheet(
                    isPresented: isPresented,
                    onDismiss: { self.onDismiss?() },
                    content: { self.destination }
                )
            } else {
                Button(action: { self.isPresented.wrappedValue = true }, label: label).background(
                    CocoaHostingView {
                        _Presenter(
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
    }
}

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
}

// MARK: - Auxiliary Implementation -

extension PresentationLink {
    @usableFromInline
    struct _Presenter<Destination: View>: View {
        private let destination: Destination
        private let isPresented: Binding<Bool>
        private let onDismiss: (() -> ())?
        
        @State var id = UUID()
        
        @Environment(\.environmentBuilder) var environmentBuilder
        @Environment(\.modalPresentationStyle) var modalPresentationStyle
        
        @usableFromInline
        init(
            destination: Destination,
            isPresented: Binding<Bool>,
            onDismiss: (() -> ())?
        ) {
            self.destination = destination
            self.isPresented = isPresented
            self.onDismiss = onDismiss
        }
        
        private var presentation: AnyModalPresentation? {
            guard isPresented.wrappedValue else {
                return nil
            }
            
            return AnyModalPresentation(
                id: id,
                content: destination,
                presentationStyle: modalPresentationStyle,
                onDismiss: { self.onDismiss?() },
                resetBinding: { self.isPresented.wrappedValue = false }
            )
        }
        
        @usableFromInline
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
