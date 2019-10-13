//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CollectionView<Data: RandomAccessCollection, CellView: View>: UIViewRepresentable where Data.Element: Identifiable {
    typealias Context = UIViewRepresentableContext<Self>
    typealias UIViewType = _UICollectionView
    
    let collectionViewLayout: UICollectionViewLayout
    let data: Data
    let makeCellView: (Data.Element) -> CellView
    
    init(
        data: Data,
        collectionViewLayout: UICollectionViewLayout,
        @ViewBuilder makeCellView: @escaping (Data.Element) -> CellView
    ) {
        self.data = data
        self.collectionViewLayout = collectionViewLayout
        self.makeCellView = makeCellView
    }
    
    func makeUIView(context: Context) -> UIViewType {
        UIViewType(
            collectionViewLayout: collectionViewLayout,
            coordinator: context.coordinator,
            data: data,
            makeCellContentView: makeCellView
        )
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> _CollectionView<Data, CellView>.Coordinator {
        return .init(data: data, makeCellView: makeCellView)
    }
}

// MARK: - Implementation -

extension _CollectionView {
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        let data: Data
        let makeCellView: (Data.Element) -> CellView
        
        init(data: Data, makeCellView: @escaping (Data.Element) -> CellView) {
            self.data = data
            self.makeCellView = makeCellView
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return data.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: _UICollectionViewCell.cellIdentifier, for: indexPath) as! _UICollectionViewCell
            let cellData = data[data.index(data.startIndex, offsetBy: indexPath.item)]
            
            cell.configure(with: makeCellView(cellData), id: cellData.id)
            
            return cell
        }
    }
}

extension _CollectionView {
    final class _UICollectionViewCell: UICollectionViewCell {
        class var cellIdentifier: String {
            return String(describing: self)
        }
        
        var _contentView: UIHostingView<CellView>?
        var currentID: Data.Element.ID?
        var isHeightCached: Bool = true
        
        func configure(with view: CellView, id: Data.Element.ID) {
            guard currentID != id else {
                return
            }
            
            currentID = id
            
            if let _contentView = _contentView {
                _contentView.rootView = view
            } else {
                _contentView = UIHostingView(rootView: view)
            }
            
            _contentView.map(constrainSubview)
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
        }
    }
    
    final class _UICollectionView: UICollectionView {
        let data: Data
        let makeCellContentView: (Data.Element) -> CellView
        
        init(
            collectionViewLayout: UICollectionViewLayout,
            coordinator: Coordinator,
            data: Data,
            makeCellContentView: @escaping (Data.Element) -> CellView
        ) {
            self.data = data
            self.makeCellContentView = makeCellContentView
            
            super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
            
            backgroundColor = .clear
            dataSource = coordinator
            delegate = coordinator
            
            register(_UICollectionViewCell.self, forCellWithReuseIdentifier: _UICollectionViewCell.cellIdentifier)
        }
        
        override var intrinsicContentSize: CGSize {
            return .init(
                width: contentSize.width + contentInset.left + contentInset.right,
                height: contentSize.height + contentInset.top + contentInset.bottom
            )
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif

