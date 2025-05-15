//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

class _PlatformTableHeaderFooterView<SectionModel: Identifiable, Content: View>: UITableViewHeaderFooterView {
    weak var parent: UITableViewController!
    var item: SectionModel!
    var makeContent: ((SectionModel) -> Content)!
    
    var contentHostingController: UIHostingController<RootView>!
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if contentHostingController == nil {
            backgroundView = .init()
            backgroundView?.backgroundColor = .clear
            contentView.backgroundColor = .clear
            contentView.bounds.origin = .zero
            layoutMargins = .zero
            
            contentHostingController = UIHostingController(rootView: RootView(base: self))
            contentHostingController.view.backgroundColor = .clear
            contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            contentHostingController.willMove(toParent: parent)
            parent.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: parent)
            
            NSLayoutConstraint.activate([
                contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            contentHostingController.rootView = RootView(base: self)
        }
    }
}

extension _PlatformTableHeaderFooterView {
    struct RootView: View {
        private let id: AnyHashable
        private let content: Content
        
        init(base: _PlatformTableHeaderFooterView<SectionModel, Content>) {
            self.content = base.makeContent(base.item)
            self.id = base.item.id
        }
        
        var body: some View {
            content
                .id(id)
        }
    }
}

extension String {
    static let hostingTableViewHeaderViewIdentifier = "UIHostingTableViewHeaderView"
    static let hostingTableViewFooterViewIdentifier = "UIHostingTableViewFooterView"
}

#endif
