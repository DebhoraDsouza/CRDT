
import Foundation

//Enum Visit is used to backtrack path
enum Visit<Element: Hashable> {
  case source
  case edge(Edge<Element>)
}

//Protocol : this can be confirmed and used delegate methods;And, generices for function variable is also implemented in the protocol
protocol Graphable {
    associatedtype Element:Hashable
    func addVertex(_ value:Vertex<Element>)->Vertex<Element>
    func addEdge(_ source: Vertex<Element>, _ destn:Vertex<Element>, _ timestamp:TimeInterval?)
    func removeVertex(_ vertex:Vertex<Element>)->Vertex<Element>?
    func removeEdge(_ source:Vertex<Element>, _ destn:Vertex<Element>, _ timestamp :TimeInterval?)->Edge<Element>?
    func isVertexPresent(_ vertex:Vertex<Element>)->Bool
    func getVertices(for vertex:Vertex<Element>)->[Vertex<Element>]?
    func getEdges(_ source:Vertex<Element>)->[Edge<Element>]?
    func breadthFirstSearch(_ source: Vertex<Element>, _ destn: Vertex<Element>)->[Edge<Element>]?
    
}
