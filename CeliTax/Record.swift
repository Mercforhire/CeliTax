//
//  Record.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-30.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
enum UnitTypes : Int
{
    case UnitItem = 0
    case UnitML = 1
    case UnitL = 2
    case UnitG = 3
    case Unit100G = 4
    case UnitKG = 5
    case UnitFloz = 6
    case UnitPt = 7
    case UnitQt = 8
    case UnitGal = 9
    case UnitOz = 10
    case UnitLb = 11
    case UnitCount = 12
}

@objc
class Record : NSObject, NSCoding, NSCopying //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    static let kUnitItemKey : String = "UnitItem"
    static let kUnitMLKey : String = "UnitML"
    static let kUnitLKey : String = "UnitL"
    static let kUnitGKey : String = "UnitG"
    static let kUnit100GKey : String = "Unit100G"
    static let kUnitKGKey : String = "UnitKG"
    
    static let kUnitFlozKey : String = "UnitFloz"
    static let kUnitPtKey : String = "UnitPt"
    static let kUnitQtKey : String = "UnitQt"
    static let kUnitGalKey : String = "UnitGal"
    static let kUnitOzKey : String = "UnitOz"
    static let kUnitLbKey : String = "UnitLb"
    
    let kKeyIdentifer : String = "Identifer"
    let kKeyCatagoryID : String = "CatagoryID"
    let kKeyReceiptID : String = "ReceiptID"
    let kKeyAmount : String = "Amount"
    let kKeyQuantity : String = "Quantity"
    let kKeyUnitType : String = "UnitType"
    let kKeyDataAction : String = "DataAction"
    
    var localID : String = ""
    var catagoryID : String = "" // must match an ItemCatagory's localID
    var receiptID : String = "" // must match an Receipt's localID
    var amount : Float = 0.0
    var quantity : Int = 0
    var unitType : Int = 0 // one of the UnitTypes enum
    var dataAction : DataActionStatus = DataActionStatus.DataActionNone
    
    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.localID = decoder.decodeObjectForKey(kKeyIdentifer) as! String
        self.catagoryID = decoder.decodeObjectForKey(kKeyCatagoryID) as! String
        self.receiptID = decoder.decodeObjectForKey(kKeyReceiptID) as! String
        self.amount = decoder.decodeFloatForKey(kKeyAmount)
        self.quantity = decoder.decodeIntegerForKey(kKeyQuantity)
        self.unitType = decoder.decodeIntegerForKey(kKeyUnitType)
        self.dataAction = DataActionStatus(rawValue: decoder.decodeIntegerForKey(kKeyDataAction))!
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.localID, forKey: kKeyIdentifer)
        coder.encodeObject(self.catagoryID, forKey: kKeyCatagoryID)
        coder.encodeObject(self.receiptID, forKey: kKeyReceiptID)
        coder.encodeFloat(self.amount, forKey: kKeyAmount)
        coder.encodeInteger(self.quantity, forKey: kKeyQuantity)
        coder.encodeInteger(self.unitType, forKey: kKeyUnitType)
        coder.encodeInteger(self.dataAction.rawValue, forKey: kKeyDataAction)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = Record()
        
        copy.localID = self.localID
        copy.catagoryID = self.catagoryID
        copy.receiptID = self.receiptID
        copy.amount = self.amount
        copy.quantity = self.quantity
        copy.unitType = self.unitType
        copy.dataAction = self.dataAction
        
        return copy
    }
    
    
    func calculateTotal() -> Float
    {
        if (self.unitType == UnitTypes.UnitItem.rawValue)
        {
            return self.amount * Float(self.quantity)
        }
        else
        {
            return self.amount
        }
    }

    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
    
        json[kKeyIdentifer] = self.localID
        json[kKeyCatagoryID] = self.catagoryID
        json[kKeyReceiptID] = self.receiptID
        json[kKeyAmount] = self.amount
        json[kKeyQuantity] = self.quantity
        json[kKeyUnitType] = self.unitType
        json[kKeyDataAction] = self.dataAction.rawValue
        
        return json
    }

    func copyDataFromRecord(thisOne : Record)
    {
        self.catagoryID = thisOne.catagoryID
        self.receiptID = thisOne.receiptID
        self.amount = thisOne.amount
        self.quantity = thisOne.quantity
        self.unitType = thisOne.unitType
        self.dataAction = thisOne.dataAction
    }

    static func unitTypeStringToUnitTypeInt(unitTypeString : String) -> Int
    {
        if (unitTypeString == kUnitItemKey)
        {
            return UnitTypes.UnitItem.rawValue
        }
        else if (unitTypeString == kUnitGKey)
        {
            return UnitTypes.UnitG.rawValue
        }
        else if (unitTypeString == kUnit100GKey)
        {
            return UnitTypes.Unit100G.rawValue
        }
        else if (unitTypeString == kUnitKGKey)
        {
            return UnitTypes.UnitKG.rawValue
        }
        else if (unitTypeString == kUnitLKey)
        {
            return UnitTypes.UnitL.rawValue
        }
        else if (unitTypeString == kUnitMLKey)
        {
            return UnitTypes.UnitML.rawValue
        }
        else if (unitTypeString == kUnitFlozKey)
        {
            return UnitTypes.UnitFloz.rawValue
        }
        else if (unitTypeString == kUnitPtKey)
        {
            return UnitTypes.UnitPt.rawValue
        }
        else if (unitTypeString == kUnitQtKey)
        {
            return UnitTypes.UnitQt.rawValue
        }
        else if (unitTypeString == kUnitGalKey)
        {
            return UnitTypes.UnitGal.rawValue
        }
        else if (unitTypeString == kUnitOzKey)
        {
            return UnitTypes.UnitOz.rawValue
        }
        else if (unitTypeString == kUnitLbKey)
        {
            return UnitTypes.UnitLb.rawValue
        }
        
        return -1
    }

    static func unitTypeIntToUnitTypeString(unitTypeInt : Int) -> String?
    {
        switch (unitTypeInt)
        {
        case UnitTypes.UnitItem.rawValue:
            return kUnitItemKey
            
        case UnitTypes.UnitML.rawValue:
            return kUnitMLKey

        case UnitTypes.UnitL.rawValue:
            return kUnitLKey

            
        case UnitTypes.UnitG.rawValue:
            return kUnitGKey

            
        case UnitTypes.Unit100G.rawValue:
            return kUnit100GKey

            
        case UnitTypes.UnitKG.rawValue:
            return kUnitKGKey

            
        case UnitTypes.UnitFloz.rawValue:
            return kUnitFlozKey

        case UnitTypes.UnitPt.rawValue:
            return kUnitPtKey

            
        case UnitTypes.UnitQt.rawValue:
            return kUnitQtKey

            
        case UnitTypes.UnitGal.rawValue:
            return kUnitGalKey

            
        case UnitTypes.UnitOz.rawValue:
            return kUnitOzKey

            
        case UnitTypes.UnitLb.rawValue:
            return kUnitLbKey
            
        default:
            return nil
        }
    }
}