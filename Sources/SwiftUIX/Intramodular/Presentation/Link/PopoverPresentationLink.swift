//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct PopoverPresentationLink<Destination: View, Label: View>: PresentationLinkView {
    private let arrowEdge: Edge = .top
    private let destination: Destination
    private let label: Label
    private let onDismiss: (() -> ())?
    
    @Environment(\._environmentInsertions) private var environmentInsertions
    #if os(iOS) || targetEnvironment(macCatalyst)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Environment(\.userInterfaceIdiom) private var userInterfaceIdiom

    @State private var isPresented: Bool = false
    
    var isPresentedBinding: Binding<Bool> {
        $isPresented.onSet {
            if self.isPresented == true && $0 == false {
                self.onDismiss?()
            }
        }
    }
    
    private var isHorizontalCompact: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
        
    public var body: some View {
        if userInterfaceIdiom == .phone {
            #if os(iOS)
            PresentationLink(isPresented: $isPresented) {
                popoverContent
            } label: {
                label
            }
            .modalPresentationStyle(.popover(permittedArrowDirections: [.init(arrowEdge)]))
            #else
            Button(toggle: $isPresented, label: { label })
                .popover(isPresented: isPresentedBinding) {
                    popoverContent
                }
            #endif
        } else if isHorizontalCompact {
            Button(toggle: $isPresented, label: { label })
                .sheet(isPresented: isPresentedBinding) {
                    popoverContent
                }
        } else {
            Button(toggle: $isPresented, label: { label })
                .popover(isPresented: isPresentedBinding) {
                    popoverContent
                }
        }
    }
    
    private var popoverContent: some View {
        destination
            .environment(environmentInsertions)
            ._resolveAppKitOrUIKitViewControllerIfAvailable()
    }
}

extension PopoverPresentationLink {
    public init(
        destination: Destination,
        onDismiss: (() -> ())?,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.label = label()
        self.onDismiss = onDismiss
    }
    
    public init(
        destination: Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            destination: destination,
            onDismiss: nil,
            label: label
        )
    }
}

#endif
