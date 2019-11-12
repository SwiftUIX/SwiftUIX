//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A workaround for `View.sheet` presentation bugs.
///
/// Wrap your `NavigationView` in this, and use `SheetPresentationLink` within.
public struct SheetPresentationView<Body: View>: View {
    @Environment(\.presentationManager) private var presentationManager
    
    @State private var presentedView: AnyView? = nil
    @State private var onDismiss: (() -> ())? = nil
    @State private var isPresented: Bool = false
    
    public let _body: Body
    
    public init(@ViewBuilder body: () -> Body) {
        self._body = body()
    }
    
    public var isSheetPresented: Binding<Bool> {
        .init(
            get: { self.isPresented },
            set: { newValue in
                if newValue {
                    self.present()
                } else {
                    self.dismiss()
                }
            }
        )
    }
    
    private func present() {
        isPresented = true
    }
    
    private func dismiss() {
        presentationManager.dismiss()
        
        isPresented = false
        presentedView = nil
        
        onDismiss?()
    }
    
    private func sheetContent() -> some View {
        presentedView!
            .environment(\.isSheetPresented, isSheetPresented)
            .environment(\.onSheetPresentationDismiss, .init($onDismiss))
            ._wrapAsPresentationSheetView()
    }
    
    public var body: some View {
        return _body
            .environment(\.isSheetPresented, isSheetPresented)
            .environment(\.onSheetPresentationDismiss, .init($onDismiss))
            .environment(\.presentedSheetView, .init($presentedView))
            .sheet(
                isPresented: $isPresented,
                onDismiss: dismiss,
                content: sheetContent
            )
    }
}

// MARK: - Helpers -

struct IsSheetPresentedViewEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<Bool>? {
        return nil
    }
}

struct PresentedSheetViewEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<AnyView?>? {
        return nil
    }
}

struct OnSheetPresentationDismissEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<(() -> ())?>? {
        return nil
    }
}

extension EnvironmentValues {
    var isSheetPresented: Binding<Bool>? {
        get {
            self[IsSheetPresentedViewEnvironmentKey.self]
        } set {
            self[IsSheetPresentedViewEnvironmentKey.self] = newValue
        }
    }
    
    var presentedSheetView: Binding<AnyView?>? {
        get {
            self[PresentedSheetViewEnvironmentKey.self]
        } set {
            self[PresentedSheetViewEnvironmentKey.self] = newValue
        }
    }
    
    var onSheetPresentationDismiss: Binding<(() -> ())?>? {
        get {
            self[OnSheetPresentationDismissEnvironmentKey.self]
        } set {
            self[OnSheetPresentationDismissEnvironmentKey.self] = newValue
        }
    }
}

extension View {
    func _wrapAsPresentationSheetView() -> some View {
        SheetPresentationView {
            self
        }
    }
}
