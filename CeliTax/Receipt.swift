//
//  Receipt.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-31.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class Receipt : NSObject, NSCoding, NSCopying  //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyIdentifer : String = "Identifer"
    let kKeyFileNames : String = "FileNames"
    let kKeyDateCreated : String = "DateCreated"
    let kKeyTaxYear : String = "TaxYear"
    let kKeyDataAction : String = "DataAction"
    
    var localID : String = ""
    var fileNames : NSMutableArray = NSMutableArray()
    var dateCreated : NSDate?
    var taxYear : Int = 0
    var dataAction : DataActionStatus = DataActionStatus.DataActionNone
    
    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.localID = decoder.decodeObjectForKey(kKeyIdentifer) as! String
        
        let fileNames : NSArray = decoder.decodeObjectForKey(kKeyFileNames) as! NSArray
        self.fileNames = NSMutableArray(array: fileNames)
        
        self.dateCreated = decoder.decodeObjectForKey(kKeyDateCreated) as? NSDate
        self.taxYear = decoder.decodeIntegerForKey(kKeyTaxYear)
        self.dataAction = DataActionStatus(rawValue: decoder.decodeIntegerForKey(kKeyDataAction))!
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.localID, forKey: kKeyIdentifer)
        coder.encodeObject(self.fileNames, forKey: kKeyFileNames)
        coder.encodeObject(self.dateCreated, forKey: kKeyDateCreated)
        coder.encodeInteger(self.taxYear, forKey: kKeyTaxYear)
        coder.encodeInteger(self.dataAction.rawValue, forKey: kKeyDataAction)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = Receipt()
        
        copy.localID = self.localID
        copy.dateCreated = self.dateCreated
        copy.fileNames = self.fileNames
        copy.taxYear = self.taxYear
        copy.dataAction = self.dataAction
        
        return copy
    }
    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kKeyIdentifer] = self.localID
        json[kKeyFileNames] = self.fileNames
        
        if (self.dateCreated != nil)
        {
            //convert self.dateCreated to String
            let gmtDateFormatter : NSDateFormatter = NSDateFormatter()
            gmtDateFormatter.timeZone = NSTimeZone.init(forSecondsFromGMT: 0)
            gmtDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString : String = gmtDateFormatter.stringFromDate(self.dateCreated!)
            
            json[kKeyDateCreated] = dateString
        }
        
        json[kKeyTaxYear] = self.taxYear
        json[kKeyDataAction] = self.dataAction.rawValue
        
        return json
    }
    
    func copyDataFromReceipt(thisOne : Receipt)
    {
        self.dateCreated = thisOne.dateCreated
        self.fileNames = thisOne.fileNames
        self.taxYear = thisOne.taxYear
        self.dataAction = thisOne.dataAction
    }
}