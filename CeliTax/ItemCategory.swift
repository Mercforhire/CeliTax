//
//  Category.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-31.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class ItemCategory : NSObject, NSCoding, NSCopying  //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kKeyIdentifer : String = "Identifer"
    private let kKeyName : String = "Name"
    private let kKeyColor : String = "Color"
    private let kKeyNationalAverageCost : String = "NationalAverageCosts"
    private let kKeyDataAction : String = "DataAction"
    
    var localID : String = ""
    var name : String = ""
    var color: UIColor = UIColor.whiteColor()
    var nationalAverageCosts : NSMutableDictionary = NSMutableDictionary()
    var dataAction : DataActionStatus = DataActionStatus.DataActionNone
    
    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        self.localID = decoder.decodeObjectForKey(kKeyIdentifer) as! String
        self.name = decoder.decodeObjectForKey(kKeyName) as! String
        self.color = decoder.decodeObjectForKey(kKeyColor) as! UIColor
        
        let nationalAverageCosts : NSDictionary = decoder.decodeObjectForKey(kKeyNationalAverageCost) as! NSDictionary
        self.nationalAverageCosts = NSMutableDictionary(dictionary: nationalAverageCosts)
        
        self.dataAction = DataActionStatus(rawValue: decoder.decodeIntegerForKey(kKeyDataAction))!
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.localID, forKey: kKeyIdentifer)
        coder.encodeObject(self.name, forKey: kKeyName)
        coder.encodeObject(self.color, forKey: kKeyColor)
        coder.encodeObject(self.nationalAverageCosts, forKey: kKeyNationalAverageCost)
        coder.encodeInteger(self.dataAction.rawValue, forKey: kKeyDataAction)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = ItemCategory()
        
        copy.localID = self.localID
        copy.name = self.name
        copy.color = self.color
        copy.nationalAverageCosts = self.nationalAverageCosts
        copy.dataAction = self.dataAction
        
        return copy
    }
    
    private func colorToJson(color : UIColor) -> NSDictionary
    {
        let kKeyRed : String = "Red"
        let kKeyGreen : String = "Green"
        let kKeyBlue : String = "Blue"
        
        let json : NSMutableDictionary = NSMutableDictionary()
    
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        json[kKeyRed] = red
        
        json[kKeyGreen] = green
        
        json[kKeyBlue] = blue
        
        return json
    }

    
    func toJson() -> Dictionary<String, AnyObject>
    {
        var json = Dictionary<String, AnyObject>()
        
        json[kKeyIdentifer] = self.localID
        
        json[kKeyName] = self.name
        
        json[kKeyColor] = self.colorToJson(self.color) 
        
        //Convert self.nationalAverageCosts dictionary to a string looking like:
        //item:2.5,ml:1.0:l:5.0,g:6.0,kg:5
        var stringOfNationAverageCosts : String = ""
        
        var firstItem : Bool = true
        
        for key in self.nationalAverageCosts.allKeys
        {
            let valueForKey : Float = self.nationalAverageCosts.objectForKey(key) as! Float
            
            let unitNameAndDollarAmount : String = String(format: "%@:%.2f", key as! String, valueForKey)
            
            if (firstItem)
            {
                stringOfNationAverageCosts = unitNameAndDollarAmount
                
                firstItem = false
            }
            else
            {
                stringOfNationAverageCosts = stringOfNationAverageCosts.stringByAppendingFormat(",%@", unitNameAndDollarAmount)
            }
        }
        
        json[kKeyNationalAverageCost] = stringOfNationAverageCosts
        
        json[kKeyDataAction] = self.dataAction.rawValue
        
        return json
    }
    
    func copyDataFromCategory(thisOne : ItemCategory)
    {
        self.name = thisOne.name
        self.color = thisOne.color
        self.nationalAverageCosts = thisOne.nationalAverageCosts
        self.dataAction = thisOne.dataAction
    }
    
    func addOrUpdateNationalAverageCostForUnitType(unitType : UnitTypes, amount : Float)
    {
        switch (unitType)
        {
        case .UnitItem:
            
            self.nationalAverageCosts[Record.kUnitItemKey] = amount
            
            break
            
        case .UnitML:
            
            self.nationalAverageCosts[Record.kUnitMLKey] = amount
            
            break
            
        case .UnitL:
            
            self.nationalAverageCosts[Record.kUnitLKey] = amount
            
            break
            
        case .UnitG:
            
            self.nationalAverageCosts[Record.kUnitGKey] = amount
            
            break
            
        case .Unit100G:
            
            self.nationalAverageCosts[Record.kUnit100GKey] = amount
            
            break
            
        case .UnitKG:
            
            self.nationalAverageCosts[Record.kUnitKGKey] = amount
            
            break
            
        case .UnitFloz:
            
            self.nationalAverageCosts[Record.kUnitFlozKey] = amount
            
            break
            
        case .UnitPt:
            
            self.nationalAverageCosts[Record.kUnitPtKey] = amount
            
            break
            
        case .UnitQt:
            
            self.nationalAverageCosts[Record.kUnitQtKey] = amount
            
            break
            
        case .UnitGal:
            
            self.nationalAverageCosts[Record.kUnitGalKey] = amount
            
            break
            
        case .UnitOz:
            
            self.nationalAverageCosts[Record.kUnitOzKey] = amount
            
            break
            
        case .UnitLb:

            self.nationalAverageCosts[Record.kUnitLbKey] = amount
            
            break
            
        default:
            
            break
        }
    }
    
    func deleteNationalAverageCostForUnitType(unitType : UnitTypes)
    {
        switch (unitType)
        {
        case .UnitItem:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitItemKey)
            
            break
            
        case .UnitML:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitMLKey)
            
            break
            
        case .UnitL:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitLKey)
            
            break
            
        case .UnitG:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitGKey)
            
            break
            
        case .Unit100G:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnit100GKey)
            
            break
            
        case .UnitKG:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitKGKey)
            
            break
            
        case .UnitFloz:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitFlozKey)
            
            break
            
        case .UnitPt:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitPtKey)
            
            break
            
        case .UnitQt:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitQtKey)
            
            break
            
        case .UnitGal:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitGalKey)
            
            break
            
        case .UnitOz:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitOzKey)
            
            break
            
        case .UnitLb:
            
            self.nationalAverageCosts.removeObjectForKey(Record.kUnitLbKey)
            
            break
            
        default:
            
            break
        }
    }
}