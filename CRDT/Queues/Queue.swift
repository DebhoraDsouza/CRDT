
import Foundation

//First in First Out(FIFO), This is used to add every vertex and their neighs in BFS(breadth First Search) to have smoother way to get the path
public struct Queue<T> {
    
    fileprivate var list = LinkedList<T>()
    
 
    //MARK:Basic functions and properties of queue
    
    //Check if the queue is empty
    public var isEmpty:Bool{
        list.isEmpty
    }
    
    //Add element to queue : add to the end of the list
    //Structure cannot muate within the declarationa nd hence using mutating
    mutating public func enqueue(_ element:T){
        list.append(value: element)
    }
    
    
    mutating public func dequeue()->T?{
        guard !list.isEmpty, let element = list.head   else {
            return nil
        }
        list.remove(element)
        return element.value
    }
    
    public func peek()->T?{
        list.head?.value

    }
}

