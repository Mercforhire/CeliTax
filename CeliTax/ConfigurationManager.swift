//
//  ConfigurationManager.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-12.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
enum UnitSystem : Int
{
    case Metric = 0
    case Imperial = 1
}

@objc
class ConfigurationManager : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private let kKeyAppSettings : String = "AppSettings"
    private let kKeyTaxYear : String = "TaxYear"
    private let kKeyLanguage : String = "Language"
    private let kKeyUnitSystem : String = "UnitSystem"
    
    private let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    private var settings : Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
    
    override init()
    {
        super.init()
    }
    
    func loadSettingsFromPersistence()
    {
        //load previous Settings
        let settings : Dictionary<String, AnyObject>? = self.defaults.objectForKey(kKeyAppSettings) as? Dictionary<String, AnyObject>
        
        if (settings != nil)
        {
            self.settings = settings!
        }
    }
    
    func saveSettings()
    {
        self.defaults.setObject(self.settings, forKey: kKeyAppSettings)
        
        self.defaults.synchronize()
    }
    
    func fetchTaxYear() -> Int
    {
        return self.settings[kKeyTaxYear] as! Int
    }
    
    func setCurrentTaxYear(taxYear : Int)
    {
        self.settings[kKeyTaxYear] = taxYear
        
        self.saveSettings()
    }
    
    func fetchUnitType() -> UnitSystem
    {
        let unitSystemSelection : Int? = self.settings[kKeyUnitSystem] as? Int
        
        if (unitSystemSelection != nil)
        {
            return UnitSystem.init(rawValue: unitSystemSelection!)!
        }
    
        return UnitSystem.Metric
    }
    
    func setUnitType(unitSystem : UnitSystem)
    {
        self.settings[kKeyUnitSystem] = unitSystem.rawValue
    
        self.saveSettings()
    }
}