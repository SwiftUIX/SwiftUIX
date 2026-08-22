//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS) 

import SwiftUI
import AppKit

public final class WindowTabController_3: ObservableObject {
    private var windowControllers: [WindowController_3] = []

    public init() {}

    public func openTab<V: View>(
        title: String,
        configure: ((NSWindow) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> V
    ) {
        let newView = content()
        let windowController = WindowController_3(view: newView)
        guard let window = windowController.window else { return }

        window.title = title
        window.tabbingMode = .preferred
        configure?(window)

        if let mainWindow = NSApp.keyWindow {
            mainWindow.addTabbedWindow(window, ordered: .above)
        }

        windowController.showWindow(nil)
        windowControllers.append(windowController)
    }
}

public class WindowController_3: NSWindowController {
    public init<V: View>(view: V) {
        let window = NSWindow()
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        let hostingView = NSHostingView(rootView: view)
        window.contentView = hostingView
        window.tabbingMode = .preferred

        super.init(window: window)

        window.isReleasedWhenClosed = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct WindowTabController_3Key: EnvironmentKey {
    static let defaultValue: WindowTabController_3 = .init()
}

public extension EnvironmentValues {
    var windowTabController_3: WindowTabController_3 {
        get { self[WindowTabController_3Key.self] }
        set { self[WindowTabController_3Key.self] = newValue }
    }
}

public struct WindowTabControllerProvider_3<Content: View>: View {
    @StateObject private var controller = WindowTabController_3()
    public let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.windowTabController_3, controller)
    }
}

#endif
