//
//  RecordsDAO.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class RecordsDAO : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private weak var userDataDAO : UserDataDAO!
    private weak var categoriesDAO : CategoriesDAO!
    
    override init()
    {
        super.init()
    }
    
    init(userDataDAO : UserDataDAO!, categoriesDAO : CategoriesDAO!)
    {
        self.userDataDAO = userDataDAO
        self.categoriesDAO = categoriesDAO
    }
    
    /**
    @return NSString ID of the new record added, nil if error occurred
    */
    func addRecordForCategory(category : ItemCategory!, receipt : Receipt!, quantity : Int, unitType : UnitTypes, amount : Float, save : Bool) -> String?
    {
        let newRecord : Record = Record()
        
        newRecord.localID = Utils.generateUniqueID()
        newRecord.categoryID = category.localID
        newRecord.receiptID = receipt.localID
        newRecord.quantity = quantity
        newRecord.unitType = unitType
        newRecord.amount = amount
        newRecord.dataAction = DataActionStatus.DataActionInsert
        
        //set it back to userData and save it
        self.userDataDAO.addRecord(newRecord)
        
        if (save)
        {
            if (self.userDataDAO.saveUserData())
            {
                return newRecord.localID
            }
        }
        else
        {
            return newRecord.localID
        }
        
        return nil
    }
    
    
    /**
    @return NSString ID of the new record added, nil if error occurred
    */
    func addRecordForCategoryID(categoryID : String, receiptID : String, quantity : Int, unitType : UnitTypes, amount : Float, save : Bool)  -> String?
    {
        let category : ItemCategory? = self.categoriesDAO.fetchCategory(categoryID)
        
        if (category != nil)
        {
            let newRecord : Record = Record()
            
            newRecord.localID = Utils.generateUniqueID()
            newRecord.categoryID = categoryID
            newRecord.receiptID = receiptID
            newRecord.quantity = quantity
            newRecord.unitType = unitType
            newRecord.amount = amount
            newRecord.dataAction = DataActionStatus.DataActionInsert
            
            //set it back to userData and save it
            self.userDataDAO.addRecord(newRecord)
            
            if (save)
            {
                if (self.userDataDAO.saveUserData())
                {
                    return newRecord.localID
                }
            }
            else
            {
                return newRecord.localID
            }
        }
        
        return nil;
    }
    
    /**
    @return YES if success, NO if user not found or records is nil
    */
    func addRecords(records : [Record], save : Bool) -> Bool
    {
        if (self.userDataDAO.addRecords(records))
        {
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
    
    /**
    @return YES if success, NO if record is not found in existing database
    */
    func modifyRecord(record : Record!, save : Bool) -> Bool
    {
        let recordToModify : Record? = self.fetchRecord(record.localID)
        
        if (recordToModify != nil)
        {
            recordToModify!.quantity = record.quantity;
            recordToModify!.amount = record.amount;
            recordToModify!.unitType = record.unitType;
            recordToModify!.categoryID = record.categoryID
            recordToModify!.receiptID = record.receiptID
            
            if (recordToModify!.dataAction != DataActionStatus.DataActionInsert)
            {
                recordToModify!.dataAction = DataActionStatus.DataActionUpdate
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
        else
        {
            return false
        }
    }
    
    /**
    @return YES if success, NO if user not found or category not found
    */
    func deleteRecordsForRecordIDs(recordIDs : [String]!, save : Bool)-> Bool
    {
        if ( recordIDs.count == 0 )
        {
            return true
        }
        
        let findRecords : NSPredicate = NSPredicate.init(format: "localID in %@", recordIDs)
        
        let recordsToDelete : [Record] = (self.fetchRecords() as NSArray).filteredArrayUsingPredicate(findRecords) as! [Record]
        
        if ( recordsToDelete.count == 0 )
        {
            return false
        }
    
        for recordToDelete in recordsToDelete
        {
            recordToDelete.dataAction = DataActionStatus.DataActionDelete
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
    
    
    func mergeWith(records : [Record]!, save : Bool) -> Bool
    {
        let localRecords : NSMutableArray = NSMutableArray.init(array: self.fetchRecords())
        
        for record in records
        {
            //find any existing Record with same id as this new one
            let findRecord : NSPredicate = NSPredicate.init(format: "localID == %@", record.localID)
            
            let existingRecord : NSArray = localRecords.filteredArrayUsingPredicate(findRecord)
            
            if (existingRecord.count > 0)
            {
                let existing : Record! = existingRecord.firstObject as! Record
                
                existing.copyDataFromRecord(record)
                
                existing.dataAction = DataActionStatus.DataActionNone
                
                localRecords.removeObject(existing)
            }
            else
            {
                //add new record if doesn't exist
                self.userDataDAO.addRecord(record)
            }
        }
        
        //for any local Record that the server doesn't have and isn't marked DataActionInsert,
        //we need to set these to DataActionInsert again so that can be uploaded to the server next time
        for data in localRecords
        {
            if let record = data as? Record
            {
                record.dataAction = DataActionStatus.DataActionInsert
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
    
    /**
     @return NSArray of Records, nil if user not found
     */
    func fetchRecords() -> [Record]!
    {
        let filterRecords : NSPredicate = NSPredicate.init(format: "dataAction != %ld", DataActionStatus.DataActionDelete.rawValue)
        let records : [Record]! = (self.userDataDAO.getRecords() as NSArray).filteredArrayUsingPredicate(filterRecords) as! [Record]
        
        return records
    }
    
    /**
     @param catagoryID NSString ID of catagory's records to load
     
     @return NSArray of Records, nil if user not found or category not found
     */
    func fetchRecordsforCategory(categoryID : String!) -> [Record]!
    {
        let findRecords : NSPredicate = NSPredicate.init(format: "categoryID == %@", categoryID)
        
        let records : [Record]! = (self.fetchRecords() as NSArray).filteredArrayUsingPredicate(findRecords) as! [Record]
        
        return records
    }
    
    /**
     @param recordID NSString ID of record to load
     
     @return Record, nil if not found
     */
    func fetchRecord(recordID : String) -> Record?
    {
        let findRecord : NSPredicate = NSPredicate.init(format: "localID == %@", recordID)
        
        let record : [Record]! = (self.fetchRecords() as NSArray).filteredArrayUsingPredicate(findRecord) as! [Record]
        
        return record.first
    }
    
    func fetchRecordsforReceipt(receiptID : String) -> [Record]!
    {
        let findRecords : NSPredicate = NSPredicate.init(format: "receiptID == %@", receiptID)
        
        let records : [Record]! = (self.fetchRecords() as NSArray).filteredArrayUsingPredicate(findRecords) as! [Record]
        
        return records
    }
    
    func fetchRecordsOfCategory(categoryID : String!, receiptID : String!) -> [Record]!
    {
        let allRecordsForReceipt : NSArray = self.fetchRecordsforReceipt(receiptID)
        
        let findRecordsWithGivenCategoryIDAndReceiptID : NSPredicate = NSPredicate.init(format: "categoryID == %@", categoryID)
        
        let recordsWithGivenCategoryIDAndReceiptID : [Record]! = allRecordsForReceipt.filteredArrayUsingPredicate(findRecordsWithGivenCategoryIDAndReceiptID) as! [Record]
        
        return recordsWithGivenCategoryIDAndReceiptID
    }
    
    func fetchRecordsOfCategory(categoryID : String!, unitType : UnitTypes, receiptID : String!) -> [Record]!
    {
        let allRecordsForReceiptAndCategory : NSArray = self.fetchRecordsOfCategory(categoryID, receiptID: receiptID)
        
        let findRecordsWithGivenUnitType : NSPredicate = NSPredicate.init(format: "unitType == %ld", unitType.rawValue)
        
        let recordsWithGivenReceiptIDCategoryIDAndUnitType : [Record]! = allRecordsForReceiptAndCategory.filteredArrayUsingPredicate(findRecordsWithGivenUnitType) as! [Record]
        
        return recordsWithGivenReceiptIDCategoryIDAndUnitType
    }
}