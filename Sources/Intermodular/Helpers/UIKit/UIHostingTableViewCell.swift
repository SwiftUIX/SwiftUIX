//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol opaque_UIHostingTableViewCellProtocol {
    func reload(with animation: UITableView.RowAnimation)
}

public class UIHostingTableViewCell<Item: Identifiable, Content: View> : UITableViewCell {
    private struct RowManager: ListRowManager {
        weak var uiTableViewCell: UIHostingTableViewCell<Item, Content>?
        
        func _reload() {
            uiTableViewCell?.reload(with: .none)
        }
    }

    private struct RootView: View {
        let content: Content
        let id: Item.ID
        let rowManager: RowManager
        
        var body: some View {
            content
                .environment(\.listRowManager, rowManager)
                .id(id)
        }
    }
    
    var tableViewController: UITableViewController!
    var indexPath: IndexPath?
    
    var item: Item!
    var makeContent: ((Item) -> Content)!
    
    var useAutoLayout = true
    
    private var contentHostingController: UIHostingController<RootView>!
    
    private var rootView: RootView {
        RootView(
            content: makeContent(item),
            id: item.id,
            rowManager: RowManager(uiTableViewCell: self)
        )
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIHostingTableViewCell {
    func update() {
        if contentHostingController == nil {
            backgroundColor = .clear
            backgroundView = .init()
            contentView.backgroundColor = .clear
            contentView.bounds.origin = .zero
            layoutMargins = .zero
            selectedBackgroundView = .init()
            
            contentHostingController = UIHostingController(rootView: rootView)
            contentHostingController.view.backgroundColor = .clear
            
            if useAutoLayout {
                contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            contentHostingController.willMove(toParent: tableViewController)
            tableViewController.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: tableViewController)
            
            if useAutoLayout {
                NSLayoutConstraint.activate([
                    contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            }
        } else {
            contentHostingController.rootView = rootView
        }
        
        if !useAutoLayout {
            contentHostingController.view.frame.size.width = bounds.width // FIXME!
            contentHostingController.view.frame.size.height = contentHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        }
    }
    
    func reset() {
        contentHostingController.willMove(toParent: nil)
        contentHostingController.view.removeFromSuperview()
        contentHostingController.removeFromParent()
        contentHostingController = nil
        
        update()
    }
}

// MARK: - Protocol Implementations -

extension UIHostingTableViewCell: opaque_UIHostingTableViewCellProtocol {
    public func reload(with animation: UITableView.RowAnimation) {
        guard let indexPath = indexPath else {
            return
        }
        
        tableViewController.tableView.reloadRows(at: [indexPath], with: animation)
    }
}

// MARK: - Helpers -

extension String {
    static let hostingTableViewCellIdentifier = "UIHostingTableViewCell"
}

#endif
