//
// Copyright (c) Vatsal Manot
//

import _SwiftUIX
import SwiftUI
import UniformTypeIdentifiers

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol _SwiftUI_DropInfoProtocol {
    var location: CGPoint { get }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func hasItemsConforming(to contentTypes: [UTType]) -> Bool
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    func itemProviders(for contentTypes: [UTType]) -> [NSItemProvider]
}

#if os(macOS)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
@_documentation(visibility: internal)
public struct _SwiftUIX_DropInfo: _SwiftUI_DropInfoProtocol {
    public let location: CGPoint
    
    fileprivate let draggingInfo: NSDraggingInfo
    
    package init(draggingInfo: NSDraggingInfo, in view: NSView) {
        self.draggingInfo = draggingInfo
        self.location = draggingInfo.draggingLocation
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func hasItemsConforming(to contentTypes: [UTType]) -> Bool {
        return draggingInfo.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: nil)
    }
    
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public func itemProviders(for contentTypes: [UTType]) -> [NSItemProvider] {
        draggingInfo.itemProviders
    }
}
#elseif os(iOS) || os(visionOS)
import UIKit

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
@_documentation(visibility: internal)
public struct _SwiftUIX_DropInfo: _SwiftUI_DropInfoProtocol {
    public let location: CGPoint
    
    fileprivate let dropSession: UIDropSession
    
    public init(location: CGPoint, dropSession: UIDropSession) {
        self.location = location
        self.dropSession = dropSession
    }
    
    public init(dropSession: UIDropSession, in view: UIView) {
        self.dropSession = dropSession
        self.location = dropSession.location(in: view)
    }
    
    public func hasItemsConforming(to contentTypes: [UTType]) -> Bool {
        return dropSession.hasItemsConforming(toTypeIdentifiers: contentTypes.map { $0.identifier })
    }
    
    public func itemProviders(for contentTypes: [UTType]) -> [NSItemProvider] {
        return dropSession.items.compactMap {
            $0.itemProvider
        }
    }
}
#endif

// MARK: - Supplementary

#if os(macOS)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension NSTextView {
    @objc open func _SwiftUIX_draggingEntered(
        _ sender: NSDraggingInfo
    ) -> NSDragOperation {
        if let `self` = self as? (any _PlatformTextViewType) {
            if #available(macOS 13.0, *) {
                guard let dropDelegate = self._SwiftUIX_textViewConfiguration.dropDelegate else {
                    return []
                }
                
                let dropInfo = self._convertToDropInfo(sender)
                
                if dropDelegate.validateDrop(info: dropInfo) {
                    dropDelegate.dropEntered(info: dropInfo)
                    return .copy
                }
                
                return []
            } else {
                assertionFailure()
                
                return []
            }
        } else {
            let dropInfo = _SwiftUIX_DropInfo(draggingInfo: sender, in: self)
            if dropInfo.hasItemsConforming(to: [.fileURL]) {
                return .copy
            }
            return []
        }
    }
    
    public func _SwiftUIX_characterOffset(
        for info: some _SwiftUI_DropInfoProtocol
    ) -> Int? {
        assert(type(of: info) == _SwiftUIX_DropInfo.self)
        
        if let info = info as? _SwiftUIX_DropInfo {
            let dropPoint = convert(info.draggingInfo.draggingLocation, from: nil)
            let caretLocation = characterIndexForInsertion(at: dropPoint)
            
            return caretLocation
        } else {
            assertionFailure()
            
            return nil
        }
    }
    
    @objc open func _SwiftUIX_performDragOperation(
        _ sender: NSDraggingInfo
    ) -> Bool {
        let dropInfo = _SwiftUIX_DropInfo(draggingInfo: sender, in: self)
        
        if let `self` = self as? (any _PlatformTextViewType) {
            if #available(macOS 13.0, *) {
                guard let dropDelegate = self._SwiftUIX_textViewConfiguration.dropDelegate else {
                    return false
                }
                
                let dropInfo = self._convertToDropInfo(sender)
                
                return dropDelegate.performDrop(info: dropInfo)
            } else {
                assertionFailure()
                
                return false
            }
        } else {
            let itemProviders = dropInfo.itemProviders(for: [.fileURL])
            
            guard let itemProvider = itemProviders.first else {
                return false
            }
            
            let point = convert(dropInfo.location, from: nil)
            let characterIndex = _SwiftUIX_layoutManager?.characterIndex(
                for: point,
                in: _SwiftUIX_textContainer!,
                fractionOfDistanceBetweenInsertionPoints: nil
            )
            
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier as String, options: nil) { [weak self] (item, error) in
                guard let self = self,
                      let url = item as? URL,
                      url.isFileURL,
                      let characterIndex = characterIndex else {
                    return
                }
                
                DispatchQueue.main.async {
                    let attachment = NSTextAttachment(fileWrapper: try? FileWrapper(url: url))
                    let attributedString = NSAttributedString(attachment: attachment)
                    self.textStorage?.insert(attributedString, at: characterIndex)
                }
            }
            
            return true
        }
    }
    
    @objc open func _SwiftUIX_draggingUpdated(
        _ sender: any NSDraggingInfo
    ) -> NSDragOperation {
        if let `self` = self as? (any _PlatformTextViewType) {
            let dropInfo = _convertToDropInfo(sender)
            
            if #available(macOS 13.0, *) {
                guard let dropDelegate = self._SwiftUIX_textViewConfiguration.dropDelegate else {
                    return []
                }
                
                if let dropProposal = dropDelegate.dropUpdated(info: dropInfo) {
                    do {
                        if let operation = try NSDragOperation(_from: dropProposal.operation) {
                            return operation
                        } else {
                            return [] // FIXME: ?
                        }
                    } catch {
                        return [] // FIXME: ?
                    }
                }
            } else {
                assertionFailure()
                
                return []
            }
            
            return []
        } else {
            return .copy
        }
    }
    
    @objc open func _SwiftUIX_draggingExited(
        _ sender: (any NSDraggingInfo)?
    ) {
        guard let sender else {
            return
        }
        
        if let `self` = self as? (any _PlatformTextViewType) {
            if #available(macOS 13.0, *) {
                let dropInfo = _convertToDropInfo(sender)
                
                self._SwiftUIX_textViewConfiguration.dropDelegate?.dropExited(info: dropInfo)
            } else {
                assertionFailure()
            }
        }
    }
    
    public func _convertToDropInfo(_ info: NSDraggingInfo) -> _SwiftUIX_DropInfo {
        _SwiftUIX_DropInfo(draggingInfo: info, in: self)
    }
}

#elseif os(iOS) || os(visionOS)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension UITextView {
    func _SwiftUIX_dropInteraction(
        _ interaction: UIDropInteraction,
        sessionDidUpdate session: UIDropSession
    ) -> UIDropProposal {
        let dropInfo = _SwiftUIX_DropInfo(dropSession: session, in: self)
        if dropInfo.hasItemsConforming(to: [.fileURL]) {
            return UIDropProposal(operation: .copy)
        }
        return UIDropProposal(operation: .cancel)
    }
    
    func _SwiftUIX_dropInteraction(
        _ interaction: UIDropInteraction,
        performDrop session: UIDropSession
    ) -> Bool {
        let dropInfo = _SwiftUIX_DropInfo(dropSession: session, in: self)
        let itemProviders = dropInfo.itemProviders(for: [.fileURL])
        
        for itemProvider in itemProviders {
            itemProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] (item, error) in
                guard let self = self,
                      let url = item as? URL,
                      url.isFileURL else {
                    return
                }
                
                let point = self.convert(dropInfo.location, from: nil)
                let characterIndex = self.layoutManager.characterIndex(for: point, in: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                let attachment = NSTextAttachment(data: try? Data(contentsOf: url), ofType: url.pathExtension)
                let attributedString = NSAttributedString(attachment: attachment)
                
                self.textStorage.insert(attributedString, at: characterIndex)
            }
        }
        return true
    }
}
#endif

// MARK: - Auxiliary

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension DropInfo: _SwiftUI_DropInfoProtocol {
    
}

#if os(macOS)
extension NSDragOperation {
    public struct _DropOperationForbiddenError: Error {
        
    }
    
    public init?(_from operation: DropOperation) throws {
        switch operation {
            case .cancel:
                return nil
            case .forbidden:
                throw _DropOperationForbiddenError()
            case .copy:
                self = .copy
            case .move:
                self = .move
                
            default:
                assertionFailure()
                
                self = .copy
        }
    }
}
#endif
