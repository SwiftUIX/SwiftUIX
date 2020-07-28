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
    let destination: Destination
    @usableFromInline
    let onDismiss: (() -> ())?
    @usableFromInline
    let label: Label
    
    @State var isPresented: Bool = false
    
    @usableFromInline
    @Environment(\.environmentBuilder) var environmentBuilder
    @usableFromInline
    @Environment(\.managedObjectContext) var managedObjectContext
    @usableFromInline
    @Environment(\.modalPresentationStyle) var modalPresentationStyle
    
    @inlinable
    public init(
        destination: Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Button(action: { self.isPresented = true }, label: { label })
            .background(
                CocoaHostingView {
                    _Presenter(
                        destination: destination
                            .managedObjectContext(managedObjectContext)
                            .mergeEnvironmentBuilder(environmentBuilder)
                            .modalPresentationStyle(modalPresentationStyle),
                        isActive: $isPresented,
                        onDismiss: onDismiss
                    )
                    .mergeEnvironmentBuilder(environmentBuilder)
                    .modalPresentationStyle(modalPresentationStyle)
                }
            )
    }
}

// MARK: - Auxiliary Implementation -

extension PresentationLink {
    @usableFromInline
    struct _Presenter<Destination: View>: View {
        private let destination: Destination
        private let isActive: Binding<Bool>
        private let onDismiss: (() -> ())?
        
        @State var id = UUID()
        
        @Environment(\.environmentBuilder) var environmentBuilder
        @Environment(\.modalPresentationStyle) var modalPresentationStyle
        
        @usableFromInline
        init(
            destination: Destination,
            isActive: Binding<Bool>,
            onDismiss: (() -> ())?
        ) {
            self.destination = destination
            self.isActive = isActive
            self.onDismiss = onDismiss
        }
        
        private var activePresentation: AnyModalPresentation? {
            guard isActive.wrappedValue else {
                return nil
            }
            
            return AnyModalPresentation(
                id: id,
                content: destination,
                presentationStyle: modalPresentationStyle,
                onDismiss: { self.onDismiss?() },
                resetBinding: { self.isActive.wrappedValue = false }
            )
        }
        
        @usableFromInline
        var body: some View {
            Group {
                if modalPresentationStyle == .automatic {
                    ZeroSizeView().sheet(
                        isPresented: isActive,
                        onDismiss: { self.onDismiss?() },
                        content: { CocoaHostingView(rootView: self.destination) }
                    )
                } else {
                    ZeroSizeView().preference(
                        key: AnyModalPresentation.PreferenceKey.self,
                        value: activePresentation
                    )
                }
            }
        }
    }
}
