//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftUI

public struct SheetPresentationView<Body: View>: View {
    @State private var presentedView: AnyView? = nil
    @State private var onDismiss: (() -> ())? = nil

    public let _body: Body

    public init(@ViewBuilder body: () -> Body) {
        self._body = body()
    }

    public var isPresenting: Binding<Bool> {
        return .init(
            getValue: { self.presentedView != nil },
            setValue: { self.presentedView = $0 ? self.presentedView : nil }
        )
    }

    public var body: some View {
        return _body
            .environment(\.presentedSheetView, $presentedView)
            .environment(\.onSheetPresentationDismiss, $onDismiss)
            .sheet(
                isPresented: isPresenting,
                onDismiss: dismiss,
                content: content
            )
    }

    func content() -> some View {
        (presentedView ?? .init(EmptyView()))
            .environment(\.isPresented, isPresenting)
            ._wrapAsPresentationSheetView()
    }

    func dismiss() {
        presentedView = nil
        onDismiss?()
    }
}

// MARK: - Helpers -

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
