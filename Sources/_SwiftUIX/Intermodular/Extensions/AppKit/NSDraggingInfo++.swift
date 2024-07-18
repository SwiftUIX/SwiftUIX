//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension NSDraggingInfo {
    package var itemProviders: [NSItemProvider] {
        guard let pasteboardItems = self.draggingPasteboard.pasteboardItems else {
            return []
        }
        
        let items = pasteboardItems.map { (pasteboardItem: NSPasteboardItem) in
            let itemProvider = NSItemProvider()
            let pasteboardItemBox = _SwiftUIX_UnsafeSendableReferenceBox(wrappedValue: pasteboardItem)
            
            for type in pasteboardItem.types {
                itemProvider.registerDataRepresentation(forTypeIdentifier: type.rawValue, visibility: .all) { completion in
                    Task { @MainActor in
                        if let data = pasteboardItemBox.wrappedValue.data(forType: type) {
                            Task { @MainActor in
                                completion(data, nil)
                            }
                        } else {
                            Task { @MainActor in
                                completion(nil, NSError(domain: "DataErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data could not be fetched for type \(type.rawValue)"]))
                            }
                        }
                    }
                    
                    return nil
                }
            }
            
            return itemProvider
        }
        
        if items.isEmpty && !_alt_fileURLs.isEmpty {
            assertionFailure("unimplemented")
        }
        
        return items
    }
    
    package var _alt_fileURLs: [URL] {
        let filenames: [String] = self.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType._filenames) as? [String] ?? []
        
        return filenames.map {
            URL(fileURLWithPath: $0)
        }
    }
}

extension NSPasteboard.PasteboardType {
    package static var _filenames = NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
}

#endif
