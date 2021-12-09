

import Foundation


//Edge is added between the source and destination and the time intevertal is also saved at the time the edge is added, source and destination is mandatory
struct Edge<T:Hashable>  {
    var source:Vertex<T>
    var destination:Vertex<T>
    var timestamp:TimeInterval
    
    //init with value : since generic anything can be added but it needs to be hasable and comparable
    public init(_ source:Vertex<T>, _ destn:Vertex<T>, _ time:TimeInterval = TimeInterval(Date().timeIntervalSince1970) ) {
        self.source = source
        destination = destn
        timestamp = time
    }
}

extension Edge:Hashable{
    public func hash(into hasher: inout Hasher) {
        return hasher.combine("\(source)\(destination)")
    }
    
    //Below functions can be used to check comparibilty based of custom conditions as we need
    static public func == (lhs:Edge<T>, rhs:Edge<T>)->Bool{
        return lhs.source == rhs.source && lhs.destination == rhs.destination
    }
    
    //hard compare : All the elemets and properties should be equal
    static public func === (lhs:Edge<T>, rhs:Edge<T>)->Bool{
        return lhs.source === rhs.source && lhs.destination === rhs.destination && lhs.timestamp == rhs.timestamp
    }
    
    
    static public func !== (lhs:Edge<T>, rhs:Edge<T>)->Bool{
        return lhs.source !== rhs.source && lhs.destination !== rhs.destination && lhs.timestamp != rhs.timestamp
    }
    
    //One edge is < other edge based on timestamp(timestamp should be lesser)
    static public func < (lhs:Edge<T>, rhs:Edge<T>)->Bool{
        return  lhs.timestamp < rhs.timestamp
    }
}

extension Edge:CustomStringConvertible{
    public var description: String{
        return "\(source)-->\(destination)"
    }
}

