//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS) 

import SwiftUI
import AppKit

public final class WindowTabController_1: ObservableObject {
    private var windows: [NSWindow] = []

    public init() {}

    public func openTab<V: View>(
        title: String,
        configuration: WindowConfigurable_1 = DefaultWindowConfiguration_1(),
        @ViewBuilder content: @escaping () -> V
    ) {
        let view = content()
        let window = createWindow(with: view, title: title)
        configuration.configure(window)

        if let mainWindow = NSApp.keyWindow {
            mainWindow.addTabbedWindow(window, ordered: .above)
        }

        window.makeKeyAndOrderFront(nil)
        windows.append(window)
    }

    private func createWindow<V: View>(with content: V, title: String) -> NSWindow {
        let window = NSWindow()
        window.title = title
        window.contentView = NSHostingView(rootView: content)
        return window
    }
}

public protocol WindowConfigurable_1 {
    func configure(_ window: NSWindow)
}

public struct DefaultWindowConfiguration_1: WindowConfigurable_1 {
    public init() {}

    public func configure(_ window: NSWindow) {
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.tabbingMode = .preferred
    }
}

public struct WindowTabController_1Key: EnvironmentKey {
    public static let defaultValue: WindowTabController_1 = .init()
}

public extension EnvironmentValues {
    var windowTabController_1: WindowTabController_1 {
        get { self[WindowTabController_1Key.self] }
        set { self[WindowTabController_1Key.self] = newValue }
    }
}

public struct WindowTabControllerProvider_1<Content: View>: View {
    @StateObject private var controller = WindowTabController_1()
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.windowTabController_1, controller)
    }
}

#endif
