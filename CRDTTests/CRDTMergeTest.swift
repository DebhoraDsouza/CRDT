
import XCTest


class CRDTMergeTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: CRDT feature test Associativity, Idempotency, Commutative
    func testAssociativity(){
        let one = P2PGraph<String>()
        let _ =  one.addVertex(Vertex("rose", 1))
        
        let two = P2PGraph<String>()
        let _ =  two.addVertex(Vertex("lily",2))
        
        let three = P2PGraph<String>()
        let _ =  three.addVertex(Vertex("lotus",3))
        
        let graph1 = (one + two) + three
        let graph2 = one + (two + three)
        
        XCTAssert(graph1==graph2, "Error! Not CRDT , as it has to be associative.")
        
    }
    
    func testIdempotency(){
        let one = P2PGraph<String>()
        let _ =  one.addVertex(Vertex("rose", 1))
        XCTAssert(one == one + one, "Error! Duplication should not occur, when same element is added.")
    }
    
    func testCommutative(){
        let one = P2PGraph<String>()
        let _ =  one.addVertex(Vertex("rose", 1))
        
        let two = P2PGraph<String>()
        let _ =  two.addVertex(Vertex("lily",2))
        
        XCTAssert(one + two == two + one, "Order in which graph is merged should not matter.")
    }
    
    
    //MARK: Merge to graphs or replica
    //Create two graphs and merge
    //rhs graph has remove edge bteween vertex two and 3
    func testMerge(){
        let graphOne = P2PGraph<String>()
        let vertexOne =  graphOne.addVertex(Vertex("rose", 1))
        let vertextTwo = graphOne.addVertex(Vertex("lotus", 2))
        let vertexThree = graphOne.addVertex(Vertex("water lily", 4))

        graphOne.addEdge(vertexOne, vertextTwo, 5)
        graphOne.addEdge(vertextTwo, vertexThree, 6)
        
        //removing vertex and adding edge to it later last test case
        _ = graphOne.removeVertex(Vertex("lily",7))

        
        let graphTwo = P2PGraph<String>()
        let rhsVertexOne =  graphTwo.addVertex(Vertex("lily",3))
        let rhsVertextTwo = graphTwo.addVertex(Vertex("rose",3))
        let rhsVertexThree = graphTwo.addVertex(Vertex("water lily",5))


        graphTwo.addEdge(rhsVertexOne, rhsVertextTwo, 10)
        graphTwo.addEdge(rhsVertextTwo, rhsVertexThree, nil)
        let removedEdge = graphTwo.removeEdge(rhsVertextTwo, rhsVertexThree, nil)
        
        //Trying to remove vertex before adding : the verxtexAdditons set will consist the vertex as removeal tried to happen before adding a vertex
        _ = graphOne.removeVertex(Vertex("water lily",3))
        graphTwo.addEdge(rhsVertexOne, rhsVertextTwo, nil)



        //Removing vertex that is not present: Will not be prsent in vertexRemoval as it is not prsent in vertextAdditons
         let marigold = graphTwo.removeVertex(Vertex("marigold",7))
        let merged = graphOne + graphTwo
        
        XCTAssertFalse(merged.vertexRemovals.contains(where: {$0.key==marigold?.value}), "Error! As merigold was never added, it should not be in removal.") // marigold never exists
        XCTAssertTrue(merged.vertexAdditions.filter({$0.key==vertexOne.value}).first?.value == 3, "Error! vertex rose should have a timestamp == 3 i.e: last updated time.")
        XCTAssertTrue(merged.isVertexPresent(rhsVertexThree), "Error! vertex \"water lily\" should be prsent as removal(at timestamp-3) was called before adding(at timestamp-5) a timestamp == 3 i.e: last updated time.")
        XCTAssertTrue(merged.edgeRemovals.contains(where: {$0.key==removedEdge}), "Error! \(String(describing: removedEdge)) should be in edgeRemovals!")
        
        //Tombstone check
        XCTAssertTrue(merged.isVertexPresent(rhsVertexOne), "Error! Since we have implemented P2 Set, this should avoid tombstone when edge is added to a removed vertex")

    }

}
