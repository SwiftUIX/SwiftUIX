//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public class UIHostingTableViewCell<ItemType: Identifiable, Content: View>: UITableViewCell {
    var tableViewController: UITableViewController!
    var indexPath: IndexPath?
    
    var item: ItemType!
    var makeContent: ((ItemType) -> Content)!
    
    var contentHostingController: UIHostingController<RootView>!
    
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
    
    public func reload(with animation: UITableView.RowAnimation) {
        guard let indexPath = indexPath else {
            return
        }
        
        tableViewController.tableView.reloadRows(at: [indexPath], with: animation)
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
            
            contentHostingController = UIHostingController(rootView: RootView(uiTableViewCell: self))
            contentHostingController.view.backgroundColor = .clear
            contentHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            contentHostingController.willMove(toParent: tableViewController)
            tableViewController.addChild(contentHostingController)
            contentView.addSubview(contentHostingController.view)
            contentHostingController.didMove(toParent: tableViewController)
            
            NSLayoutConstraint.activate([
                contentHostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                contentHostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentHostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentHostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        } else {
            contentHostingController.rootView = RootView(uiTableViewCell: self)
            contentHostingController.view.invalidateIntrinsicContentSize()
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

// MARK: - Auxiliary Implementation -

extension UIHostingTableViewCell {
    struct RootView: View {
        private struct _ListRowManager: ListRowManager {
            var isHighlighted: Bool {
                false // FIXME!!!
            }
            
            weak var uiTableViewCell: UIHostingTableViewCell<ItemType, Content>?
            
            func _animate(_ action: () -> ()) {
                uiTableViewCell?.tableViewController.tableView.beginUpdates()
                action()
                uiTableViewCell?.tableViewController.tableView.endUpdates()
            }
            
            func _reload() {
                uiTableViewCell?.reload(with: .none)
            }
        }
        
        private let item: ItemType
        private let makeContent: (ItemType) -> Content
        private let listRowManager: _ListRowManager
        
        init(uiTableViewCell: UIHostingTableViewCell<ItemType, Content>) {
            self.item = uiTableViewCell.item
            self.makeContent = uiTableViewCell.makeContent
            self.listRowManager = .init(uiTableViewCell: uiTableViewCell)
        }
        
        var body: some View {
            makeContent(item)
                .environment(\.listRowManager, listRowManager)
                .id(item.id)
        }
    }
}

// MARK: - Helpers -

extension String {
    static let hostingTableViewCellIdentifier = "UIHostingTableViewCell"
}

#endif
