//
//  TaxYearsDAO.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class TaxYearsDAO : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private weak var userDataDAO : UserDataDAO!
    
    override init()
    {
        super.init()
    }
    
    init(userDataDAO : UserDataDAO!)
    {
        self.userDataDAO = userDataDAO
    }
    
    func loadAllTaxYears() -> [Int]
    {
        let loadTaxYears : NSPredicate = NSPredicate.init(format: "dataAction != %ld", DataActionStatus.DataActionDelete.rawValue)
        let taxYearsObjects : [TaxYear] = (self.userDataDAO.getTaxYears() as NSArray).filteredArrayUsingPredicate(loadTaxYears) as! [TaxYear]
        
        var taxYearNumbers : [Int] = []
        
        for taxYear in taxYearsObjects
        {
            taxYearNumbers.append(taxYear.taxYear)
        }
        
        return taxYearNumbers
    }
    
    func existTaxYear(taxYear : Int) -> Bool
    {
        let findTaxYear : NSPredicate = NSPredicate.init(format: "dataAction != %ld AND taxYear == %ld", DataActionStatus.DataActionDelete.rawValue, taxYear)
        let taxYearsObjects : [TaxYear] = (self.userDataDAO.getTaxYears() as NSArray).filteredArrayUsingPredicate(findTaxYear) as! [TaxYear]
        
        return taxYearsObjects.count > 0
    }
    
    func addTaxYear(taxYear : Int, save : Bool) -> Bool
    {
        if (taxYear > 2000 && !self.existTaxYear(taxYear))
        {
            let taxTearObject : TaxYear = TaxYear()
            taxTearObject.taxYear = taxYear
            taxTearObject.dataAction = DataActionStatus.DataActionInsert
            
            self.userDataDAO.addTaxYear(taxTearObject)
            
            if (save)
            {
                return self.userDataDAO.saveUserData()
            }
            else
            {
                return true
            }
        }
        
        return false
    }
    
    func mergeWith(taxyears : [TaxYear], save : Bool) -> Bool
    {
        let localTaxyears : NSMutableArray = NSMutableArray.init(array: self.userDataDAO.getTaxYears())
        
        for taxyear in taxyears
        {
            //find any existing Taxyear with same year as this new one
            let findTaxyear : NSPredicate = NSPredicate.init(format: "taxYear == %ld", taxyear.taxYear)
            
            let existingYear : NSArray = localTaxyears.filteredArrayUsingPredicate(findTaxyear)
            
            if (existingYear.count == 0)
            {
                //add new tax year if doesn't exist
                self.userDataDAO.addTaxYear(taxyear)
            }
            else
            {
                let existing : TaxYear! = existingYear.firstObject as! TaxYear
                
                localTaxyears.removeObject(existing)
            }
        }
        
        //for any local TaxYear that the server doesn't have and isn't marked DataActionInsert,
        //we need to set these to DataActionInsert again so that can be uploaded to the server next time
        for data in localTaxyears
        {
            if let taxYear = data as? TaxYear
            {
                taxYear.dataAction = DataActionStatus.DataActionInsert
            }
        }
        
        if (save)
        {
            return self.userDataDAO.saveUserData()
        }
        else
        {
            return true
        }
    }
}