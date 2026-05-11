//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS)

import SwiftUI
import AppKit
import Combine

public struct WindowTab: Identifiable, Hashable {
    public let id: UUID
    public let title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

public protocol WindowTabControllerDelegate: AnyObject {
    func tabDidOpen(_ tab: WindowTab)
    func tabDidClose(_ id: UUID)
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

public enum WindowCommand {
    case open(title: String, content: () -> AnyView)
    case close(id: UUID)
    case focus(id: UUID)
}

public final class WindowTabController_2: ObservableObject {
    @Published public private(set) var tabs: [WindowTab] = []

    public weak var delegate: WindowTabControllerDelegate?

    public let tabOpened = PassthroughSubject<WindowTab, Never>()
    public let tabClosed = PassthroughSubject<UUID, Never>()

    private var windowMap: [UUID: NSWindow] = [:]
    private let configuration: WindowConfigurable

    public init(configuration: WindowConfigurable = DefaultWindowConfiguration()) {
        self.configuration = configuration
    }

    public func perform(_ command: WindowCommand) {
        switch command {
        case let .open(title, content):
            let id = UUID()
            let view = content()
            let window = createWindow(with: view, title: title)
            configuration.configure(window)

            if let mainWindow = NSApp.keyWindow {
                mainWindow.addTabbedWindow(window, ordered: .above)
            }

            window.makeKeyAndOrderFront(nil)
            let tab = WindowTab(id: id, title: title)
            tabs.append(tab)
            windowMap[id] = window

            delegate?.tabDidOpen(tab)
            tabOpened.send(tab)

        case let .close(id):
            if let window = windowMap[id] {
                window.close()
                windowMap.removeValue(forKey: id)
                tabs.removeAll { $0.id == id }
                delegate?.tabDidClose(id)
                tabClosed.send(id)
            }

        case let .focus(id):
            windowMap[id]?.makeKeyAndOrderFront(nil)
        }
    }

    private func createWindow(with content: AnyView, title: String) -> NSWindow {
        let window = NSWindow()
        window.title = title
        window.contentView = NSHostingView(rootView: content)
        return window
    }
}

private struct WindowTabController_2Key: EnvironmentKey {
    static let defaultValue: WindowTabController_2 = .init()
}

public extension EnvironmentValues {
    var windowTabController_2: WindowTabController_2 {
        get { self[WindowTabController_2Key.self] }
        set { self[WindowTabController_2Key.self] = newValue }
    }
}

public struct WindowTabControllerProvider_2<Content: View>: View {
    @StateObject private var controller = WindowTabController_2()
    public let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.windowTabController_2, controller)
    }
}

#endif
