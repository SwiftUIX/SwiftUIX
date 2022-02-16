//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CollectionViewCellOrSupplementaryViewContainer<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
>: View {
    struct Configuration {
        typealias ContentConfiguration = _CollectionViewCellOrSupplementaryViewConfiguration<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
        typealias ContentState = _CollectionViewCellOrSupplementaryViewState<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
        typealias ContentPreferences = _CollectionViewCellOrSupplementaryViewPreferences<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
        typealias ContentCache = _CollectionViewCellOrSupplementaryViewCache<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
        
        let _reuseCellRender: Bool
        let _collectionViewProxy: CollectionViewProxy
        let _cellProxyBase: _CellProxyBase?
        var contentConfiguration: ContentConfiguration
        let contentState: ContentState?
        let contentPreferences: Binding<ContentPreferences>?
        let contentCache: ContentCache
        let content: _CollectionViewCellOrSupplementaryViewContent
    }
    
    var configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }

    var body: some View {
        if configuration._reuseCellRender {
            contentView
                .background(
                    ZeroSizeView()
                        .id(configuration.contentConfiguration.id)
                        .allowsHitTesting(false)
                        .accessibility(hidden: true)
                )
        } else {
            contentView
                .id(configuration.contentConfiguration.id)
        }
    }
    
    private var contentView: some View {
        configuration
            .content
            .environment(\._cellProxy, .init(base: configuration._cellProxyBase))
            .environment(\._collectionViewProxy, .init(.constant(configuration._collectionViewProxy)))
            .transformEnvironment(\._relativeFrameResolvedValues) { value in
                guard let preferences = configuration.contentPreferences else {
                    return
                }
                
                guard let relativeFrameID = preferences.wrappedValue.relativeFrame?.id else {
                    if let preferredContentSize = configuration.contentCache.preferredContentSize {
                        if value[0] == nil {
                            value[0] = .init(
                                width: preferredContentSize.width,
                                height: preferredContentSize.height
                            )
                        }
                    }
                    
                    return
                }
                
                guard let preferredContentSize = configuration.contentCache.preferredContentSize else {
                    return
                }
                
                value[relativeFrameID] = .init(
                    width: preferredContentSize.width,
                    height: preferredContentSize.height
                )
            }
            .environment(\.isCellFocused, configuration.contentState?.isFocused ?? false)
            .environment(\.isCellHighlighted, configuration.contentState?.isHighlighted ?? false)
            .environment(\.isCellSelected, configuration.contentState?.isSelected ?? false)
            .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self) {
                guard let preferences = configuration.contentPreferences else {
                    return
                }
                
                if preferences._collectionOrListCellPreferences.wrappedValue != $0 {
                    preferences._collectionOrListCellPreferences.wrappedValue = $0
                }
            }
            .onPreferenceChange(DragItem.PreferenceKey.self) {
                guard let preferences = configuration.contentPreferences else {
                    return
                }
                
                if preferences.dragItems.wrappedValue != $0 {
                    preferences.dragItems.wrappedValue = $0
                }
            }
            .onPreferenceChange(RelativeFrame.PreferenceKey.self) {
                guard let preferences = configuration.contentPreferences else {
                    return
                }
                
                if preferences.relativeFrame.wrappedValue != $0.last {
                    preferences.relativeFrame.wrappedValue = $0.last
                }
            }
    }
}

extension _CollectionViewCellOrSupplementaryViewContainer {
    init<SectionHeaderContent, SectionFooterContent, CellContent>(base: UIHostingCollectionViewSupplementaryView<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, CellContent>) {
        self.init(
            configuration: .init(
                _reuseCellRender: false,
                _collectionViewProxy: .init(base.parentViewController),
                _cellProxyBase: nil,
                contentConfiguration: base.configuration!,
                contentState: nil,
                contentPreferences: nil,
                contentCache: base.cache,
                content: base.content
            )
        )
    }
}

#endif
