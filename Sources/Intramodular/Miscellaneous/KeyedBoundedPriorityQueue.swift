//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

final class KeyedBoundedPriorityQueue<Key: Hashable, Value> {
    private class Node {
        var key: Key
        var value: Value
        var next: Node?
        
        weak var previous: Node?
        
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }

    var maximumCapacity: Int?
    
    private var nodes: [Key: Node] = [:]
    private var head: Node?
    private var tail: Node?
        
    init(maximumCapacity: Int? = 100) {
        self.maximumCapacity = maximumCapacity
    }
    
    private func appendNode(_ node: Node) {
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
                removeFirstNode()
            }
        }
    }
    
    private func removeNode(_ node: Node) {
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
    
    private func removeFirstNode() {
        head.map(removeNode)
    }
    
    private func removeLastNode() {
        tail.map(removeNode)
    }
    
    private func moveNodeToLast(_ node: Node) {
        guard node !== tail else {
            return
        }
        
        removeNode(node)
        appendNode(node)
    }
}

extension KeyedBoundedPriorityQueue {
    var count: Int {
        nodes.count
    }
    
    var first: Value? {
        head?.value
    }
    
    var last: Value? {
        tail?.value
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            nodes[key]?.value
        } set {
            guard let newValue = newValue else {
                nodes[key].map(removeNode)
                return
            }
            
            if let node = nodes[key] {
                node.value = newValue
                moveNodeToLast(node)
            } else {
                let node = Node(key: key, value: newValue)
                appendNode(node)
            }
        }
    }
}
