

import XCTest
@testable import CRDT

class CRDTGraphTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //Basic check on add and removal of vertices and edges

    //MARK: Add Vertex
    //Check by adding the same value at different times : result; the  first time value is added as a new vertex and the timesecond time the timestamp is updated
    func testAddVertex() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //Check and see if a vextex is added successfully
        let p2pGraph = P2PGraph<String>()
        let vertex = Vertex("1")
        let vertexOne =  p2pGraph.addVertex(vertex)
        XCTAssertTrue(vertexOne.timestamp > 0.0, "Vertex \(String(describing: vertexOne)) not added !")

        let sameVertex = Vertex("1")
        let finalVertex = p2pGraph.addVertex(sameVertex)
        XCTAssertTrue(vertexOne < finalVertex, "Vertex timestamp not changed \(String(describing: vertexOne))!")

    }
    
    //MARK: Remove Vertex
    //Check by removing the same value at different times : result the second time the timestamp is updated
    func testRemoveVertex() throws{
        let p2pGraph = P2PGraph<String>()
        if let vertexOne =  p2pGraph.removeVertex(Vertex("1"))  {
            XCTAssertTrue(vertexOne.timestamp > 0.0, "Vertex not removed \(String(describing: vertexOne))!")
            if let sameVertex =  p2pGraph.removeVertex(Vertex("1")){
            XCTAssertTrue(vertexOne < sameVertex, "Vertex timestamp not changed(updated)!")
            }
        }

        
    }
    
    //MARK:Add Edges
    func testAddEdge() throws{
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        let edge = Edge(vertexOne, vertextTwo)
        p2pGraph.addEdge(vertexOne, vertextTwo, nil)
        XCTAssert((p2pGraph.edgeAdditions[edge] != nil), "Edge not added!")
    }
    
    
    //MARK:Remove Edges
    //
    func testRemoveEdge() throws{
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        p2pGraph.addEdge(vertexOne, vertextTwo, nil)

        let edge =  p2pGraph.removeEdge(vertexOne, vertextTwo, nil)
        XCTAssertTrue((edge != nil), "Edge not removed \(String(describing: vertexOne))!")
        let sameEdge =  p2pGraph.removeEdge(vertexOne, vertextTwo, nil)
        XCTAssertTrue(edge?.timestamp != sameEdge?.timestamp, "Edge timestamp not changed(updated)!")

    }
    
    
    //MARK:Test to check if a vertex is present
    //Check if a vertex is present : The same vertex present in vertexAdditions should not be present in vertexRemovals with a timestamp higher than the same element timestamp in vertexAdditons array as we dont not delete the vertex to avoid tombstone, 2P set is checked with the timestamp as well
    //Both conditions of vertex present and not present is checked in the test case
    func testIsVertexPresent(){
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        p2pGraph.addEdge(vertexOne, vertextTwo, nil)
        let isPresent = p2pGraph.isVertexPresent(vertexOne)
        XCTAssertTrue(isPresent, "Vertex not present.")
        
    
        //This is done to check if the result return is false as removal of vertex has happened in which the timestamp is later than the timestamp of vertex when added
        _ = p2pGraph.removeVertex(vertexOne)
        let notPresent = p2pGraph.isVertexPresent(vertexOne)
        XCTAssertFalse(notPresent, "Vertex is present.")
    }
    
    //MARK: List of vertices for a particular vertex
    //Check for test cases when vertex is prsent and then the same two vertices are removed is removed and the test case to check the count
    func testGetVertices(){
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        let vertexThree = Vertex("3")

        p2pGraph.addEdge(vertexOne, vertextTwo, nil)
        p2pGraph.addEdge(vertexOne, vertexThree, nil)
        let vertices = p2pGraph.getVertices(for: vertexOne)
        XCTAssertTrue(vertices?.count ?? 0 > 0, "No Vertices attached to vertex \(vertexOne)")
        
        //The 2P set : vertexRemovals will have vertexTwo and vertexThree with timestamp later than that present for same vertices in vertexAdditions
        //Currently removing edges between vertex should be called explicilty, can be improvised later
        let _ = p2pGraph.removeVertex(vertextTwo)
        let _ = p2pGraph.removeVertex(vertexThree)
        let _ = p2pGraph.removeEdge(vertexOne, vertextTwo, nil)
        let _ = p2pGraph.removeEdge(vertexOne, vertexThree, nil)

        let finalVertices = p2pGraph.getVertices(for: vertexOne)
        XCTAssertFalse(finalVertices?.count ?? 0 > 0, "No Vertices attached to vertex \(vertexOne)")
    }
    
    //MARK: Get Edges
    //timetsamp of any elemet prsent in both 2P set edgeRemoval and edgeAddtions is compared and added to the result of if the former has the same element with time stamp lesser than that present in latter. If any element does has the smae vertex as source and is not in edgeRemovals is also added to the result
    func testGetEdges(){
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        let vertexThree = Vertex("3")

        p2pGraph.addEdge(vertexOne, vertextTwo, nil)
        p2pGraph.addEdge(vertexOne, vertexThree, nil)
        let edges = p2pGraph.getEdges(vertexOne)
        XCTAssertTrue(edges?.count ?? 0 > 0, "No Vertices attached to vertex \(vertexOne)")
        
        //The 2P set : edgeRemovals will have vertexTwo and vertexThree with timestamp later than that present for same vertices in edgeAdditons
        let _ = p2pGraph.removeVertex(vertextTwo)
        let _ = p2pGraph.removeVertex(vertexThree)
        let _ = p2pGraph.removeEdge(vertexOne, vertextTwo, nil)
        let _ = p2pGraph.removeEdge(vertexOne, vertexThree, nil)

        let finalEdges = p2pGraph.getEdges(vertexOne)
        XCTAssertFalse(finalEdges?.count ?? 0 > 0, "No Vertices attached to vertex \(vertexOne)")
    }
    
    //MARK: Get path between two vertices
    //Bread First Search : Check the source and moves to its neighbours and back tracks the edges to the path
    func testBreathFirstSearch(){
        let p2pGraph = P2PGraph<String>()
        let vertexOne =  p2pGraph.addVertex(Vertex("1"))
        let vertextTwo = p2pGraph.addVertex(Vertex("2"))
        let vertexThree = Vertex("3")

        p2pGraph.addEdge(vertexOne, vertextTwo, nil)
        p2pGraph.addEdge(vertextTwo, vertexThree, nil)
        let path = p2pGraph.breadthFirstSearch(vertexOne, vertexThree)
        XCTAssertTrue(path?.count == 2 , "Path Cannot be found between \(vertexOne),\(vertexThree)")
        
        //The 2P set : Remove the path and this time the count of the path should be 0
        let _ = p2pGraph.removeVertex(vertextTwo)
        let _ = p2pGraph.removeVertex(vertexThree)
        let _ = p2pGraph.removeEdge(vertexOne, vertextTwo, nil)
        let _ = p2pGraph.removeEdge(vertexOne, vertexThree, nil)

        let finalPath = p2pGraph.getEdges(vertexOne)
        XCTAssertTrue(finalPath?.count == 0 , "Path Cannot be found between \(vertexOne),\(vertexThree)")
    }
    


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
