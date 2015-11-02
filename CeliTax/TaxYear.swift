//
//  TaxYear.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-31.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class TaxYear : NSObject, NSCoding, NSCopying //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyTaxYear : String = "TaxYear"
    let kKeyDataAction : String = "DataAction"
    
    var taxYear : Int = 0
    var dataAction : DataActionStatus = DataActionStatus.DataActionNone
    
    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.taxYear = decoder.decodeIntegerForKey(kKeyTaxYear)
        self.dataAction = DataActionStatus(rawValue: decoder.decodeIntegerForKey(kKeyDataAction))!
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeInteger(self.taxYear, forKey: kKeyTaxYear)
        coder.encodeInteger(self.dataAction.rawValue, forKey: kKeyDataAction)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = TaxYear()
        
        copy.taxYear = self.taxYear
        copy.dataAction = self.dataAction
        
        return copy
    }
    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kKeyTaxYear] = self.taxYear
        json[kKeyDataAction] = self.dataAction.rawValue
        
        return json
    }
}