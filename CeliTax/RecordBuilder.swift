//
//  RecordBuilder.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class RecordBuilder : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyIdentifer : String = "identifier"
    let kKeyCategoryID : String = "catagoryid"
    let kKeyReceiptID : String = "receiptid"
    let kKeyAmount : String = "amount"
    let kKeyQuantity : String = "quantity"
    let kKeyUnitType : String = "unit_type"
    
    func buildRecordFrom(json : NSDictionary) -> Record?
    {
        if (!json.isKindOfClass(NSDictionary))
        {
            return nil
        }
        
        let record : Record = Record()
        
        record.localID = json[kKeyIdentifer] as! String
        record.categoryID = json[kKeyCategoryID] as! String
        record.receiptID = json[kKeyReceiptID] as! String
        record.amount = json[kKeyAmount] as! Float
        record.quantity = json[kKeyQuantity] as! Int
        record.unitType = UnitTypes(rawValue: json[kKeyUnitType] as! Int)!
        
        return record
    }
}