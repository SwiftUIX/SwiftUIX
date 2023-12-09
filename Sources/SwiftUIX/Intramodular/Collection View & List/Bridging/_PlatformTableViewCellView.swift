//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(macOS)

class _PlatformTableCellView<Configuration: _CocoaListConfigurationType>: NSTableCellView {
    struct HostingContainer: View {
        var item: AnyHashable?
        var base: Configuration.ViewProvider.RowContent?
        var availableWidth: CGFloat?
        
        var body: some View {
            Group {
                if let base {
                    base
                } else {
                    Text("Unimplemented")
                }
            }
            .id(item)
        }
    }
    
    lazy var hostingView = {
        let result = NSHostingView(rootView: HostingContainer())
        
        if #available(macOS 13.0, *) {
            result.sizingOptions = .standardBounds
        }
        
        return result
    }()
    
    private var _frameDidChangeNotificationHandle: NSObjectProtocol?
    
    init() {
        super.init(frame: .zero)
        
        hostingView.rootView = HostingContainer()
        
        addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        postsFrameChangedNotifications = true
        
        _frameDidChangeNotificationHandle = NotificationCenter.default.addObserver(
            forName: NSView.frameDidChangeNotification,
            object: self,
            queue: .main,
            using: { [weak self] _ in
                self?.updateHostingView()
            }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        hostingView.rootView = HostingContainer()
    }
    
    private func updateHostingView() {
        hostingView.rootView.availableWidth = frame.width
    }
}

#endif
