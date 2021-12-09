
import Foundation

public class Node<Value>{
  public  var next:Node?
   public var value:Value
    
    init(value:Value, next:Node? = nil) {
        self.value = value
        self.next = next
    }
    

}

extension Node:CustomStringConvertible{
   public var description: String{
    
    guard let _ = next else {
        return "\(value)"
    }
    return "\(value) -> " + String(describing: next) + " "
   }
}

