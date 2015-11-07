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
    let kKeyCategoryID : String = "CatagoryID"
    let kKeyReceiptID : String = "ReceiptID"
    let kKeyAmount : String = "Amount"
    let kKeyQuantity : String = "Quantity"
    let kKeyUnitType : String = "UnitType"
    let kKeyDataAction : String = "DataAction"
    
    var localID : String = ""
    var categoryID : String = "" // must match an ItemCatagory's localID
    var receiptID : String = "" // must match an Receipt's localID
    var amount : Float = 0.0
    var quantity : Int = 0
    var unitType : UnitTypes = UnitTypes.UnitItem
    var dataAction : DataActionStatus = DataActionStatus.DataActionNone
    
    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.localID = decoder.decodeObjectForKey(kKeyIdentifer) as! String
        self.categoryID = decoder.decodeObjectForKey(kKeyCategoryID) as! String
        self.receiptID = decoder.decodeObjectForKey(kKeyReceiptID) as! String
        self.amount = decoder.decodeFloatForKey(kKeyAmount)
        self.quantity = decoder.decodeIntegerForKey(kKeyQuantity)
        self.unitType = UnitTypes(rawValue: decoder.decodeIntegerForKey(kKeyUnitType))!
        self.dataAction = DataActionStatus(rawValue: decoder.decodeIntegerForKey(kKeyDataAction))!
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.localID, forKey: kKeyIdentifer)
        coder.encodeObject(self.categoryID, forKey: kKeyCategoryID)
        coder.encodeObject(self.receiptID, forKey: kKeyReceiptID)
        coder.encodeFloat(self.amount, forKey: kKeyAmount)
        coder.encodeInteger(self.quantity, forKey: kKeyQuantity)
        coder.encodeInteger(self.unitType.rawValue, forKey: kKeyUnitType)
        coder.encodeInteger(self.dataAction.rawValue, forKey: kKeyDataAction)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = Record()
        
        copy.localID = self.localID
        copy.categoryID = self.categoryID
        copy.receiptID = self.receiptID
        copy.amount = self.amount
        copy.quantity = self.quantity
        copy.unitType = self.unitType
        copy.dataAction = self.dataAction
        
        return copy
    }
    
    
    func calculateTotal() -> Float
    {
        if (self.unitType == UnitTypes.UnitItem)
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
        json[kKeyCategoryID] = self.categoryID
        json[kKeyReceiptID] = self.receiptID
        json[kKeyAmount] = self.amount
        json[kKeyQuantity] = self.quantity
        json[kKeyUnitType] = self.unitType.rawValue
        json[kKeyDataAction] = self.dataAction.rawValue
        
        return json
    }

    func copyDataFromRecord(thisOne : Record)
    {
        self.categoryID = thisOne.categoryID
        self.receiptID = thisOne.receiptID
        self.amount = thisOne.amount
        self.quantity = thisOne.quantity
        self.unitType = thisOne.unitType
        self.dataAction = thisOne.dataAction
    }

    static func unitTypeStringToUnitType(unitTypeString : String) -> UnitTypes
    {
        if (unitTypeString == kUnitItemKey)
        {
            return UnitTypes.UnitItem
        }
        else if (unitTypeString == kUnitGKey)
        {
            return UnitTypes.UnitG
        }
        else if (unitTypeString == kUnit100GKey)
        {
            return UnitTypes.Unit100G
        }
        else if (unitTypeString == kUnitKGKey)
        {
            return UnitTypes.UnitKG
        }
        else if (unitTypeString == kUnitLKey)
        {
            return UnitTypes.UnitL
        }
        else if (unitTypeString == kUnitMLKey)
        {
            return UnitTypes.UnitML
        }
        else if (unitTypeString == kUnitFlozKey)
        {
            return UnitTypes.UnitFloz
        }
        else if (unitTypeString == kUnitPtKey)
        {
            return UnitTypes.UnitPt
        }
        else if (unitTypeString == kUnitQtKey)
        {
            return UnitTypes.UnitQt
        }
        else if (unitTypeString == kUnitGalKey)
        {
            return UnitTypes.UnitGal
        }
        else if (unitTypeString == kUnitOzKey)
        {
            return UnitTypes.UnitOz
        }
        else if (unitTypeString == kUnitLbKey)
        {
            return UnitTypes.UnitLb
        }
        
        return UnitTypes.UnitItem
    }

    static func unitTypeToUnitTypeString(unitType : UnitTypes) -> String?
    {
        switch (unitType)
        {
        case UnitTypes.UnitItem:
            return kUnitItemKey
            
        case UnitTypes.UnitML:
            return kUnitMLKey

        case UnitTypes.UnitL:
            return kUnitLKey
            
        case UnitTypes.UnitG:
            return kUnitGKey
            
        case UnitTypes.Unit100G:
            return kUnit100GKey
            
        case UnitTypes.UnitKG:
            return kUnitKGKey
            
        case UnitTypes.UnitFloz:
            return kUnitFlozKey

        case UnitTypes.UnitPt:
            return kUnitPtKey
            
        case UnitTypes.UnitQt:
            return kUnitQtKey
            
        case UnitTypes.UnitGal:
            return kUnitGalKey

        case UnitTypes.UnitOz:
            return kUnitOzKey
            
        case UnitTypes.UnitLb:
            return kUnitLbKey
            
        default:
            return nil
        }
    }
}