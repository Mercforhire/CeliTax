//
//  UserData.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-10-31.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc enum DataActionStatus : Int
{
    case DataActionNone = 0
    case DataActionInsert = 1
    case DataActionUpdate = 2
    case DataActionDelete = 3
}

@objc
class UserData : NSObject, NSCoding //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    let kKeyCategories : String  = "Catagories"
    let kKeyRecords : String = "Records"
    let kKeyReceipts : String = "Receipts"
    let kKeyTaxYears : String = "TaxYears"
    let kKeyLastUploadedDate : String = "LastUploadedDate"
    let kKeyLastUploadHash : String = "LastUploadHash"
    
    var categories : NSMutableArray = NSMutableArray()
    
    var records : NSMutableArray = NSMutableArray()
    
    var receipts : NSMutableArray = NSMutableArray()
    
    var taxYears : NSMutableArray = NSMutableArray()
    
    var lastUploadedDate : NSDate?
    
    var lastUploadHash : String?

    override init()
    {
        
    }
    
    required init(coder decoder: NSCoder)
    {
        let categories : NSArray = decoder.decodeObjectForKey(kKeyCategories) as! NSArray
        self.categories = NSMutableArray(array: categories)
        
        let records : NSArray = decoder.decodeObjectForKey(kKeyRecords) as! NSArray
        self.records = NSMutableArray(array: records)
        
        let receipts : NSArray = decoder.decodeObjectForKey(kKeyReceipts) as! NSArray
        self.receipts = NSMutableArray(array: receipts)
        
        let taxYears : NSArray = decoder.decodeObjectForKey(kKeyTaxYears) as! NSArray
        self.taxYears = NSMutableArray(array: taxYears)
        
        self.lastUploadedDate = decoder.decodeObjectForKey(kKeyLastUploadedDate) as? NSDate
        
        self.lastUploadHash = decoder.decodeObjectForKey(kKeyLastUploadHash) as? String
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(self.categories, forKey: kKeyCategories)
        coder.encodeObject(self.records, forKey: kKeyRecords)
        coder.encodeObject(self.receipts, forKey: kKeyReceipts)
        coder.encodeObject(self.taxYears, forKey: kKeyTaxYears)
        coder.encodeObject(self.lastUploadedDate, forKey: kKeyLastUploadedDate)
        coder.encodeObject(self.lastUploadHash, forKey: kKeyLastUploadHash)
    }
    
    func generateJSONToUploadToServer() -> NSDictionary
    {
        let json : NSMutableDictionary = NSMutableDictionary()
        
        let categoriesJSONs : NSMutableArray = NSMutableArray()
    
        for data in self.categories
        {
            if let category = data as? ItemCategory
            {
                if (category.dataAction != DataActionStatus.DataActionNone)
                {
                    //convert category to JSON and add to catagoriesJSONs
                    categoriesJSONs.addObject(category.toJson())
                }
            }
        }
    
        json[kKeyCategories] = categoriesJSONs
    
    
        let recordsJSONs : NSMutableArray = NSMutableArray()
    
        for data in self.records
        {
            if let record = data as? Record
            {
                if (record.dataAction != DataActionStatus.DataActionNone)
                {
                    //convert record to JSON and add to recordsJSONs
                    recordsJSONs.addObject(record.toJson())
                }
            }
        }
        
        json[kKeyRecords] = recordsJSONs
    
    
        let receiptsJSONs : NSMutableArray = NSMutableArray()
    
        for data in self.receipts
        {
            if let receipt = data as? Receipt
            {
                if (receipt.dataAction != DataActionStatus.DataActionNone)
                {
                    //convert receipt to JSON and add to receiptsJSONs
                    receiptsJSONs.addObject(receipt.toJson())
                }
            }
        }
    
        json[kKeyReceipts] = receiptsJSONs
    
    
        let taxYearsJSONs : NSMutableArray = NSMutableArray()
    
        for data in self.taxYears
        {
            if let taxYear = data as? TaxYear
            {
                if (taxYear.dataAction != DataActionStatus.DataActionNone)
                {
                    //convert receipt to JSON and add to receiptsJSONs
                    taxYearsJSONs.addObject(taxYear.toJson())
                }
            }
        }
    
        json[kKeyTaxYears] = taxYearsJSONs
    
        return json
    }
    
    func resetAllDataActionsAndClearOutDeletedOnes()
    {
        let categoriesToDelete : NSMutableArray = NSMutableArray()
    
        for data in self.categories
        {
            if let category = data as? ItemCategory
            {
                if (category.dataAction == DataActionStatus.DataActionDelete)
                {
                    categoriesToDelete.addObject(category)
                }
                else
                {
                    category.dataAction = DataActionStatus.DataActionNone;
                }
            }
        }
    
        self.categories.removeObjectsInArray(categoriesToDelete as [AnyObject])
    
    
        let recordsToDelete : NSMutableArray = NSMutableArray()
    
        for data in self.records
        {
            if let record = data as? Record
            {
                if (record.dataAction == DataActionStatus.DataActionDelete)
                {
                    recordsToDelete.addObject(record)
                }
                else
                {
                    record.dataAction = DataActionStatus.DataActionNone;
                }
            }
        }
    
        self.records.removeObjectsInArray(recordsToDelete as [AnyObject])
    
    
        let receiptsToDelete : NSMutableArray = NSMutableArray()
    
        for data in self.receipts
        {
            if let receipt = data as? Receipt
            {
                if (receipt.dataAction == DataActionStatus.DataActionDelete)
                {
                    receiptsToDelete.addObject(receipt)
                }
                else
                {
                    receipt.dataAction = DataActionStatus.DataActionNone;
                }
            }
        }
    
        self.receipts.removeObjectsInArray(receiptsToDelete as [AnyObject])
    
    
        let taxYearsToDelete : NSMutableArray = NSMutableArray()
        
        for data in self.taxYears
        {
            if let taxYear = data as? TaxYear
            {
                if (taxYear.dataAction == DataActionStatus.DataActionDelete)
                {
                    taxYearsToDelete.addObject(taxYear)
                }
                else
                {
                    taxYear.dataAction = DataActionStatus.DataActionNone;
                }
            }
        }
    
        self.taxYears.removeObjectsInArray(taxYearsToDelete as [AnyObject])
    }
}