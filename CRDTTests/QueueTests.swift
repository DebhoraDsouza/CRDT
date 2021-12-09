
import XCTest

class QueueTests: XCTestCase {

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
    
    
    //MARK: Test basic fetaures of queuue like FIFO, enqueue, dequeue, peek and isEmpty features
    func testQueue(){
        var queue = Queue<Int>()
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        
        let element = queue.dequeue()
        XCTAssert(element==1, "Queue should implement first in first out.")
        XCTAssert(queue.peek()==2, "2 should be first element, which can be dqeueued next")
        let _ = queue.dequeue()
        let _ = queue.dequeue()
        XCTAssert(queue.isEmpty, "Queue should be empty.")

    }
    

}
