//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@_spi(Internal)
public final class KeyedBoundedPriorityQueue<Key: Hashable, Value> {
    @usableFromInline
    var maximumCapacity: Int
    @usableFromInline
    var nodes: [Key: Node] = [:]
    @usableFromInline
    var head: Node?
    @usableFromInline
    var tail: Node?
    @usableFromInline
    var markedForDeletion: Set<Key> = []
    
    public init(maximumCapacity: Int) {
        self.maximumCapacity = maximumCapacity
    }
    
    @_optimize(speed)
    @usableFromInline
    func _appendNode(_ node: Node) {
        if (nodes.count - markedForDeletion.count) >= maximumCapacity {
            if let lraNode = head {
                _removeNode(lraNode)
            }
        }
        
        if let oldTail = tail {
            oldTail.next = node
            node.previous = oldTail
        } else {
            head = node
        }
        
        tail = node
        nodes[node.key] = node
    }
    
    @_optimize(speed)
    @usableFromInline
    func _removeNode(_ node: Node) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        
        if node === head {
            head = node.next
        }
        
        if node === tail {
            tail = node.previous
        }
        
        nodes.removeValue(forKey: node.key)
    }
    
    @_optimize(speed)
    @usableFromInline
    func _removeFirstValidNode() {
        while let key = head?.key, markedForDeletion.contains(key) {
            _removeNode(head!)
            markedForDeletion.remove(key)
        }
    }
    
    @_optimize(speed)
    @usableFromInline
    func _moveNodeToLast(_ node: Node) {
        guard node !== tail else {
            return
        }
        
        if node === head {
            head = node.next
        }
        
        node.next?.previous = node.previous
        node.previous?.next = node.next
        
        tail?.next = node
        node.previous = tail
        node.next = nil
        tail = node
    }
}

extension KeyedBoundedPriorityQueue {
    public var count: Int {
        @_optimize(speed)
        @inline(__always)
        get {
            nodes.count
        }
    }
    
    public var first: Value? {
        @_optimize(speed)
        @inline(__always)
        get {
            head?.value
        }
    }
    
    public var last: Value? {
        @_optimize(speed)
        @inline(__always)
        get {
            tail?.value
        }
    }
    
    @_optimize(speed)
    @inline(__always)
    public subscript(_ key: Key) -> Value? {
        get {
            nodes[key]?.value
        } set {
            guard let newValue = newValue else {
                if let existing = nodes[key] {
                    _removeNode(existing)
                }
                
                return
            }
            
            if let node = nodes[key] {
                node.value = newValue
                
                _moveNodeToLast(node)
            } else {
                let node = Node(key: key, value: newValue)
                
                _appendNode(node)
            }
        }
    }
    
    @_optimize(speed)
    @inline(__always)
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
    public func makeIterator() -> AnyIterator<(key: Key, value: Value)> {
        var current = head
        
        return AnyIterator {
            defer {
                current = current?.next
            }
            
            return current.map({ ($0.key, $0.value) })
        }
    }
}

// MARK: - Auxiliary

extension KeyedBoundedPriorityQueue {
    @usableFromInline
    class Node {
        @usableFromInline
        var key: Key
        @usableFromInline
        var value: Value
        @usableFromInline
        var next: Node?
        
        @usableFromInline
        weak var previous: Node?
        
        @usableFromInline
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
}
