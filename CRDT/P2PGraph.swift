

import Foundation

//Implementing 2P2P LWW-Set Graph to keep track of the vertices and edges and avoid tumbstones

public class P2PGraph<T:Hashable>{
    
    typealias Element = T

    //2 P2 Set are used : one set (additions, removals) of vertices and another set (additions , removals) of  edges
    internal var vertexAdditions: [T: TimeInterval] = [:]
    internal var vertexRemovals: [T: TimeInterval]
    internal var edgeAdditions: [Edge<T>: TimeInterval] = [:]
    internal var edgeRemovals: [Edge<T>: TimeInterval] = [:]
    
    
    public init(){
        vertexAdditions = [:]
        vertexRemovals = [:]
        edgeRemovals = [:]
        edgeAdditions = [:]
    }
    
    public convenience init(_ value: T) {
        self.init()
        vertexAdditions[value] = Date().timeIntervalSince1970
    }
    
}

extension P2PGraph:Graphable{

    //MARK: Add vertex or edge
    //Addition is done to 2P Set vertexAdditions and edgeAdditions for vertex and edge respectively. When an element is already present, the timestamp is compared and it is updated with latest timestamp.
    func addVertex(_ vertex: Vertex<T>) -> Vertex<Element> {
        if let oldTimeStamp = vertexAdditions[vertex.value]{
            if oldTimeStamp < vertex.timestamp {
                vertexAdditions[vertex.value] = vertex.timestamp
            }
        }else{
            vertexAdditions[vertex.value] = vertex.timestamp
        }
        return vertex
    }
    
    func addEdge(_ source: Vertex<T>, _ destn: Vertex<T>, _ timestamp: TimeInterval?) {
        let edge = Edge(source, destn, timestamp ?? Date().timeIntervalSince1970)
        if let oldEdge = edgeAdditions[edge]{
            if oldEdge < edge.timestamp{
                edgeAdditions[edge] = edge.timestamp
            }
        }else{
            edgeAdditions[edge] = edge.timestamp
        }
    
    }
    
    //MARK: Remove vertex or edge
    //Removal is done to 2P Set vertexRemovals and edgeRemovals for vertex and edge respectively. When an element is already present, the timestamp is compared and it is updated with latest timestamp.
    func removeVertex(_ vertex: Vertex<T>) -> Vertex<T>? {
        //if the item is not present in 2P set of additions i.e:vertexAdditions then do not perform remove
        guard vertexAdditions.contains(where:{$0.key==vertex.value}) else {
            return nil
        }
        if let oldValue =  vertexRemovals[vertex.value]{
            if oldValue < vertex.timestamp{
                vertexRemovals[vertex.value] = vertex.timestamp
            }
        }else{
            vertexRemovals[vertex.value] = vertex.timestamp
        }
        return vertex
    }
    
    func removeEdge(_ source: Vertex<T>, _ destn: Vertex<T>, _ timestamp: TimeInterval?) -> Edge<T>? {
        //if the item is not present in 2P set of additions i.e:vertexAdditions then do not perform remove
        let edge = Edge(source, destn, timestamp ?? Date().timeIntervalSince1970)
        guard edgeAdditions.contains(where:{$0.key==edge}) else {
            return nil
        }
        if let oldEdge = edgeRemovals[edge]{
            if oldEdge < edge.timestamp{
                edgeRemovals[edge] = edge.timestamp
            }
        }else{
            edgeRemovals[edge] = edge.timestamp
        }
        return edge
    }
    
    //MARK: Vextex present in graph
    //First we check if the same vertex is present in vertexRemoval and compare the timestamp between the element in vertexRemoval and vertextAdditions.
    //If the vertex is present in VextexRemoval it should have a lesser timetsmap than the same element in vertexAdditions, the time timestamp is time at which the element was edited. We have 2P set to aaoid tombstones and
    func isVertexPresent(_ vertex: Vertex<T>) -> Bool {
        let filteredRemoval = vertexRemovals.filter({$0.key == vertex.value})
        let filterAdditons = vertexAdditions.filter({$0.key == vertex.value})
        if filteredRemoval.count > 0{
            return  filterAdditons.contains(where: {element in element.key==vertex.value && filteredRemoval.allSatisfy({$0.value<element.value})})
        }else{
            return  filterAdditons.contains(where: {element in element.key==vertex.value})
        }
        
    }
        
    //MARK: Get list of vertices attached to a vertex
    func getVertices(for vertex: Vertex<T>) -> [Vertex<T>]? {
        let removedEdges = edgeRemovals.filter({$0.key.source==vertex})
        var  vertices : [Vertex<T>]?
        if removedEdges.count > 0{
            vertices  = edgeAdditions.filter({curElement in curElement.key.source==vertex && removedEdges.contains(where: {$0.value<curElement.value})})
                .compactMap({$0.key.destination})
        }else{
            vertices  = edgeAdditions.filter({curElement in curElement.key.source==vertex})
                .compactMap({$0.key.destination})
        }
        if vertices?.count ?? 0 > 0{
                return vertices
            }
        
        return nil
    }
    
    //MARK: Get list of vertices attached to a vertex
    //Any edge not present in 2P Set edgeRemovals and has the vertex as source and has a timestamp greater in edgeAdditions than if present in edgeRemoval will be added to edges
    func getEdges(_ source: Vertex<T>) -> [Edge<T>]? {
        
        let removedEdges = edgeRemovals.filter({$0.key.source==source})
        var  edges : [Edge<T>]?
        if removedEdges.count > 0{
            edges  = edgeAdditions.filter({curElement in curElement.key.source==source && removedEdges.contains(where: {$0.value<curElement.value})})
                .compactMap({$0.key})
        }else{
            edges  = edgeAdditions.filter({curElement in curElement.key.source==source}).compactMap({$0.key})
                
        }
        return edges
    }
    
    //MARK: Get the path between two vertices
    //To get the path we use Breadth First Search : Visit a node and then visit its neighbours recursively. Queue data structure to enqueue all the vertices and their neighbours between source and destination. A dictionary is  used with vetex and type of vertex (source, edge) to traverse through the vertices and backtrack to the path.
    func breadthFirstSearch(_ source: Vertex<T>, _ destn: Vertex<T>) -> [Edge<T>]? {
        var queue : Queue<Vertex<T>> = Queue()
        queue.enqueue(source)
        var visited : [Vertex<T>:Visit<T>] = [source:.source]
        while let visitedVertex = queue.dequeue() {
            //Once destination is reached you gow throw the dictionary of key:Vetex and Value:Edge that used to reach the destination, we save the edge in the route to get the path
            if visitedVertex == destn{
                var vertex = visitedVertex
                var route:[Edge<T>] = []
                
                //traverse until you get a source type, which is the end of while loop
                while let visit = visited[vertex],
                      case .edge(let edge) = visit{
                    route = [edge] + route
                    vertex = edge.source
                }
                return route
            }
            if let edges = getEdges(visitedVertex){
            for edge in edges {
                //if the destinationation is not present in the visited dictionary means we need to enqueue it in queue that is used travers its neighbours/children
                if visited[edge.destination] == nil{
                    queue.enqueue(edge.destination)
                    visited[edge.destination] = .edge(edge)

                }
            }
        }
    }
        return nil

    }
    
    //MARK: merge replica
    //Merge: Addition takes precedence to deletion to avaoid tombstone
    func merge(_  replica:P2PGraph<T>){
        replica.vertexAdditions.forEach{ [weak self] (vertex, timestamp) in
            _ =  self?.addVertex(Vertex(vertex,timestamp))
        }
        replica.edgeAdditions.forEach{ [weak self] (edge, timestamp) in
            self?.addEdge(edge.source, edge.destination, timestamp)
        }
        replica.vertexRemovals.forEach{ [weak self] (vertex, timestamp) in
            _ =  self?.removeVertex(Vertex(vertex, timestamp))
        }
        replica.edgeRemovals.forEach{ [weak self] (edge, timestamp) in
           _ =  self?.removeEdge(edge.source, edge.destination, timestamp)
        }
    }
    
    // + Merges two set
    public static func +(lhs: P2PGraph<T>, rhs: P2PGraph<T>) -> P2PGraph<T> {
        let merged = P2PGraph()
        merged.merge(lhs)
        merged.merge(rhs)
        return merged
    }
    
    public static func == (lhs: P2PGraph<T>, rhs: P2PGraph<T>)->Bool{
        lhs.edgeAdditions == rhs.edgeAdditions && lhs.edgeRemovals == rhs.edgeAdditions &&
            lhs.vertexAdditions == rhs.vertexAdditions && lhs.vertexRemovals == rhs.vertexRemovals
    }

}

