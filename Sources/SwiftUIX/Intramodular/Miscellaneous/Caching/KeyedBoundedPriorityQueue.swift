//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_spi(Internal)
public final class KeyedBoundedPriorityQueue<Key: Hashable, Value> {
    private var maximumCapacity: Int?
    private var nodes: [Key: Node] = [:]
    private var head: Node?
    private var tail: Node?
    
    public init(maximumCapacity: Int? = 100) {
        self.maximumCapacity = maximumCapacity
    }
    
    private func _appendNode(_ node: Node) {
        nodes[node.key] = node
        
        if let oldTail = tail {
            oldTail.next = node
            node.previous = oldTail
            tail = node
        } else {
            head = node
            tail = node
        }
        
        if let maxSize = maximumCapacity {
            if nodes.count > maxSize {
                _removeFirstNode()
            }
        }
    }
    
    private func _removeNode(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        
        if node === head {
            head = node.next
        }
        
        if node === tail {
            tail = node.previous
        }
        
        nodes[node.key] = nil
    }
    
    private func _removeFirstNode() {
        head.map(_removeNode)
    }
    
    private func _removeLastNode() {
        tail.map(_removeNode)
    }
    
    private func moveNodeToLast(_ node: Node) {
        guard node !== tail else {
            return
        }
        
        _removeNode(node)
        _appendNode(node)
    }
}

extension KeyedBoundedPriorityQueue {
    public var count: Int {
        nodes.count
    }
    
    public var first: Value? {
        head?.value
    }
    
    public var last: Value? {
        tail?.value
    }
    
    public subscript(_ key: Key) -> Value? {
        get {
            nodes[key]?.value
        } set {
            guard let newValue = newValue else {
                nodes[key].map(_removeNode)
                
                return
            }
            
            if let node = nodes[key] {
                node.value = newValue
                
                moveNodeToLast(node)
            } else {
                let node = Node(key: key, value: newValue)
                
                _appendNode(node)
            }
        }
    }
    
    public func removeValue(forKey key: Key) {
        self[key] = nil
    }
}

// MARK: - Conformances

extension KeyedBoundedPriorityQueue: ExpressibleByDictionaryLiteral {
    public convenience init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(maximumCapacity: elements.count)
        
        for (key, value) in elements {
            self[key] = value
        }
    }
}

extension KeyedBoundedPriorityQueue: Sequence {
    public typealias Iterator = AnyIterator<(key: Key, value: Value)>
    
    public func makeIterator() -> AnyIterator<(key: Key, value: Value)> {
        AnyIterator(nodes.mapValues({ $0.value }).makeIterator())
    }
}

// MARK: - Auxiliary

extension KeyedBoundedPriorityQueue {
    private class Node {
        fileprivate var key: Key
        fileprivate var value: Value
        fileprivate var next: Node?
        
        fileprivate weak var previous: Node?
        
        fileprivate init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
}
