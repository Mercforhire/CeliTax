extension String {  
  
    var lastPathComponent: String {  
         
        get {  
            return (self as NSString).lastPathComponent  
        }  
    }  
    var pathExtension: String {  
         
        get {  
             
            return (self as NSString).pathExtension  
        }  
    }  
    var stringByDeletingLastPathComponent: String {  
         
        get {  
             
            return (self as NSString).stringByDeletingLastPathComponent  
        }  
    }  
    var stringByDeletingPathExtension: String {  
         
        get {  
             
            return (self as NSString).stringByDeletingPathExtension  
        }  
    }  
    var pathComponents: [String] {  
         
        get {  
             
            return (self as NSString).pathComponents  
        }  
    }  
  
    func stringByAppendingPathComponent(path: String) -> String
    {
         
        let nsSt = self as NSString  
         
        return nsSt.stringByAppendingPathComponent(path)  
    }  
  
    func stringByAppendingPathExtension(ext: String) -> String?
    {
         
        let nsSt = self as NSString  
         
        return nsSt.stringByAppendingPathExtension(ext)  
    }
    
    func isEmailAddress() -> Bool
    {
        let filterString : String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", filterString)
        
        return emailTest.evaluateWithObject(self)
    }
    
    
    func isCanadianPostalCode() -> Bool
    {
        let postalPred : String = "[a-zA-Z][0-9][a-zA-Z]( )?[0-9][a-zA-Z][0-9]"
        let pred : NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", postalPred)
        
        return pred.evaluateWithObject(self)
    }
    
    func isAmericanPostalCode() -> Bool
    {
        let postalPred : String = "^\\d{5}([\\-]?\\d{4})?$"
        let pred : NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", postalPred)
        
        return pred.evaluateWithObject(self)
    }
    
    static func hexStringFromColor(color : UIColor) -> String
    {
        let components : UnsafePointer<CGFloat> = CGColorGetComponents(color.CGColor)
        
        let r : CGFloat = components[0]
        let g : CGFloat  = components[1]
        let b : CGFloat = components[2]
        
        return String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r) * Float(255)), lroundf(Float(g) * Float(255)), lroundf(Float(b) * Float(255)))
    }
}