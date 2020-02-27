//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class UIHostingTableViewHeaderFooterView<SectionModel: Identifiable, Content: View> : UITableViewHeaderFooterView {
    var parent: UITableViewController!
    var item: SectionModel!
    var makeContent: ((SectionModel) -> Content)!
    var useAutoLayout = true
    
    private var contentHostingController: UIViewController!
    
    var rootView: some View {
        self.makeContent(item).id(item.id)
    }
    
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
            
            contentHostingController = UIHostingController(rootView: rootView)
            contentHostingController.view.backgroundColor = .clear
            
            if useAutoLayout {
                contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            contentHostingController.willMove(toParent: parent)
            parent.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: parent)
            
            if useAutoLayout {
                NSLayoutConstraint.activate([
                    contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            }
        } else {
            (contentHostingController as? UIHostingController)?.rootView = rootView
        }
        
        if !useAutoLayout {
            contentHostingController.view.frame.size.width = bounds.width // FIXME!
            contentHostingController.view.frame.size.height = contentHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
}

extension String {
    static let hostingTableViewHeaderViewIdentifier = "UIHostingTableViewHeaderView"
    static let hostingTableViewFooterViewIdentifier = "UIHostingTableViewFooterView"
}

#endif
