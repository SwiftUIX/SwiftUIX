//
//  File.swift
//  SwiftUIX
//
//  Created by Yasir on 12/05/25.
//

#if os(macOS) 

import SwiftUI
import AppKit

public final class WindowTabManager {
    public static let shared = WindowTabManager()
    
    private var windows: [NSWindow] = []
    
    public init() {}
    
    public func addWindowToGroup(with view: some View, title: String) {
        let newWindow = NSWindow()
        newWindow.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        newWindow.title = "Tab \(UUID().uuidString.prefix(4))"
        newWindow.isReleasedWhenClosed = false
        newWindow.contentView = NSHostingView(rootView: view)
        newWindow.tabbingMode = .preferred

        if let mainWindow = NSApp.keyWindow {
            mainWindow.addTabbedWindow(newWindow, ordered: .above)
        }

        newWindow.makeKeyAndOrderFront(nil)
    }
}

#endif
