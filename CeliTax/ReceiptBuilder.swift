//
//  ReceiptBuilder.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class ReceiptBuilder : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyIdentifer : String = "identifier"
    let kKeyFileNames : String  = "filenames"
    let kKeyDateCreated : String = "date_created"
    let kKeyTaxYear : String = "tax_year"
    
    func buildReceiptFrom(json : NSDictionary) -> Receipt?
    {
        if (!json.isKindOfClass(NSDictionary))
        {
            return nil
        }
        
        let receipt : Receipt = Receipt()
        
        receipt.localID = json[kKeyIdentifer] as! String
        receipt.taxYear = json[kKeyTaxYear] as! Int
        
        //Filenames
        let filenamesString : NSString = json[kKeyFileNames] as! NSString
        
        let filenames : NSArray = filenamesString.componentsSeparatedByString(",")
        
        receipt.fileNames = NSMutableArray(array: filenames)
        
        //Data Created
        let dateString : NSString = json[kKeyDateCreated] as! NSString
        
        if (dateString.length > 0)
        {
            let gmtDateFormatter : NSDateFormatter = NSDateFormatter()
            gmtDateFormatter.timeZone = NSTimeZone.init(forSecondsFromGMT: 0)
            gmtDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let dateCreated : NSDate! = gmtDateFormatter.dateFromString(dateString as String)
            
            receipt.dateCreated = dateCreated
        }
        
        return receipt
    }
}