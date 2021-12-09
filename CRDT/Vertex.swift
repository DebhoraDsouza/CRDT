

import Foundation


public struct Vertex <T:Hashable> : Comparable, CustomStringConvertible{
    public var value:T
    public var timestamp: TimeInterval
    

    //init with value : since generic anything can be added but it needs to be hasable and comparable
    public init(_ val:T, _ time:TimeInterval = Date().timeIntervalSince1970 ) {
        value = val
        timestamp = time
    }
    
    public var description: String{
        return "\(value)"
    }

}

extension Vertex: Hashable{
    
    //you can hash the value if required, currently it is not required, we can use it later though.
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(value)
    }
    
    //check if the value is the same
    public static func ==(lhs:Vertex<T>, rhs:Vertex<T>)->Bool{
        return lhs.value == rhs.value
    }
    
    //Hard compare: check if the vertex is the same, as in; value and timestamp are same.
    public static func ===(lhs:Vertex<T>, rhs:Vertex<T>)->Bool{
        return lhs.value == rhs.value && lhs.timestamp == rhs.timestamp
    }
    
    //Hard compare: value or/and timestamp not same then the vertex is not equal.
    public static func !==(lhs:Vertex<T>, rhs:Vertex<T>)->Bool{
        return !(lhs === rhs)
    }
    
    //When a vertex is added, we check for the timestamp as well to insert/add vetext in the right position or if there is a concurrent vertext addition at the same time we need to handle merge.
    public static func < (lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}
