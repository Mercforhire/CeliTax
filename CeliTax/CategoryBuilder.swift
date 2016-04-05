//
//  CatagoryBuilder.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-01.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class CategoryBuilder : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyIdentifer : String = "identifier"
    let kKeyName : String = "name"
    let kKeyColor : String = "color"
    let kKeyNationalAverageCost : String = "national_average_cost"
    
    func buildCategoryFrom(json : NSDictionary) -> ItemCategory?
    {
        if (!json.isKindOfClass(NSDictionary))
        {
            return nil
        }
        
        let category : ItemCategory = ItemCategory()
        
        category.localID = json[kKeyIdentifer] as! String
        category.name = json[kKeyName] as! String
        
        category.nationalAverageCosts = NSMutableDictionary()
        
        //Convert a string of format 'item:2.5,ml:1.0:l:5.0,g:6.0,kg:5'
        //To Dictionary of KEY: item; VALUE: 2.5, KEY: ml; VALUE: 1.0,...
        let averageCostString : NSString = json[kKeyNationalAverageCost] as! NSString
        
        let components : NSArray = averageCostString.componentsSeparatedByString(",")
        
        for data in components
        {
            if let component = data as? NSString
            {
                let components2 : NSArray = component.componentsSeparatedByString(":")
                
                if (components2.count == 2)
                {
                    let unitName : String! = components2.firstObject as! String
                    
                    let unitValue : String! = components2.lastObject as! String
                    
                    category.nationalAverageCosts[unitName] = Float(unitValue)
                }
            }
        }
        
        let colorString : NSString = json[kKeyColor] as! NSString
        
        let colorValues : NSArray = colorString.componentsSeparatedByString(",")
        
        if (colorValues.count == 3)
        {
            let redValue : CGFloat! = CGFloat( (colorValues.firstObject as! NSString).floatValue )
            let blueValue : CGFloat! = CGFloat( (colorValues[1] as! NSString).floatValue )
            let greenValue : CGFloat! = CGFloat( (colorValues.lastObject as! NSString).floatValue )
            
            let color : UIColor! = UIColor.init(red: redValue, green: greenValue, blue: blueValue , alpha: 1)
            
            category.color = color
        }
        
        return category
    }
}