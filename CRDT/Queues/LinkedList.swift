
import Foundation

//MARK: Implemented this earlier and used the same code to support queues hence test cases are omitted
public struct LinkedList<Value> {
    public var head:Node<Value>?
    public var tail:Node<Value>?
    
    init() {}
    
   public var isEmpty:Bool{
        head == nil
    }
  
    
//MARK: Insert methods
   mutating func push(value:Value){
    
        head = Node(value:value, next:head)
        if tail == nil{
            tail = head
        }
    }
    
    mutating func append(value:Value){
        if isEmpty{
           push(value:value)
            return
        }
        tail?.next = Node(value:value, next:tail)
        tail = tail?.next
        
    }
    
   @discardableResult
    mutating func insert(value:Value, after node:Node<Value>)->Node<Value>{
        
        guard tail !== node else {
           append(value: value)
            return tail!
        }
        node.next = Node(value: value, next: node.next)
        return node.next!
        
    }
    
    func node(at index:Int)->Node<Value>?{
        var curNode = head
        var curIndex = 0
        
        while curNode != nil, curIndex < index{
            curNode = curNode?.next
            curIndex += 1
        }
        return curNode
        
    }
    
    //MARK: Delete/Remove funcs
   mutating func pop()->Value?{
        defer {
            head = head?.next
            if isEmpty{
                tail = nil
            }
        }
    return head?.value
    }
    
    mutating func removeLast()->Value?{
        
        guard let head = head else {
            return nil
        }
        guard head.next != nil else {
           return pop()
        }
        
        var prev = head
        var current = head
        
        while let next = current.next{
            prev = current
            current = next
        }
        
        prev.next = nil
        tail = prev
        return current.value
        
    }
    

    
    @discardableResult
    mutating func remove(after node:Node<Value>)->Value?{
        
        guard let node = copyNodes(returningCopyOf: node) else { return nil }

        defer {
            if node.next === tail{
                tail = node
            }
            node.next = node.next?.next
        }
        return node.next?.value
    }
    
    @discardableResult
    mutating func remove(_ node:Node<Value>)->Value?{
        
        guard let node = copyNodes(returningCopyOf: node) else { return nil }

        defer {
            if node === head{
                head = node.next
            }
            node.next = node.next?.next
        }
        return node.value
    }
    
    
    mutating func copyNodes(returningCopyOf: Node<Value>)->Node<Value>?{
        
        guard !isKnownUniquelyReferenced(&head) else {
            return nil
            
        }
        guard var oldNode = head else {
            return nil
        }
        head = Node(value:oldNode.value)
        var newNode = head
        var nodeCopy = head
        while let nextOldnode = oldNode.next {
            if nodeCopy === oldNode{
                nodeCopy = newNode
            }
            newNode?.next = Node(value:nextOldnode.value)
            newNode = newNode?.next
            oldNode = newNode!
        }
        return nodeCopy

    }
    
}

extension LinkedList:CustomStringConvertible{
   public var description: String{
        guard let curHead = head else {
            return "Empty List"
        }
        return String(describing:curHead)
    }
}

extension LinkedList: Collection{
    public func index(after i: Index) -> Index {
        Index(node:i.node?.next)
    }
    
    public subscript(position: Index) -> Value? {
        position.node?.value
    }
    
    public var startIndex: Index {
        Index(node:head)
    }
    
    public var endIndex: Index {
        Index(node:tail?.next)
    }
    
    public struct Index:Comparable{
        public var node:Node<Value>?
        static public func == (lhs:Index, rhs:Index)->Bool{
            switch (lhs.node, rhs.node) {
                 case let (left?, right?):
                   return left.next === right.next
                 case (nil, nil):
                   return true
                 default:
                   return false
                 }
        }
        public static func < (lhs:Index, rhs:Index) -> Bool {
            guard lhs != rhs else{
                return false
            }
            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node }

        }
    }
}


