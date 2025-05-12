//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

import SwiftUI
import AppKit

public final class WindowTabController: ObservableObject {
    private var windows: [NSWindow] = []

    public init() {}

    public func openTab<V: View>(
        title: String,
        configuration: WindowConfigurable = DefaultWindowConfiguration(),
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

struct WindowTab: Identifiable {
    let id = UUID()
    let title: String
    weak var window: NSWindow?
}

public protocol WindowConfigurable {
    func configure(_ window: NSWindow)
}

public struct DefaultWindowConfiguration: WindowConfigurable {
    public init() {}

    public func configure(_ window: NSWindow) {
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.tabbingMode = .preferred
    }
}

public struct WindowTabControllerKey: EnvironmentKey {
    public static let defaultValue: WindowTabController = .init()
}

public extension EnvironmentValues {
    var windowTabController: WindowTabController {
        get { self[WindowTabControllerKey.self] }
        set { self[WindowTabControllerKey.self] = newValue }
    }
}

public struct WindowTabControllerProvider<Content: View>: View {
    @StateObject private var controller = WindowTabController()
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.windowTabController, controller)
    }
}
