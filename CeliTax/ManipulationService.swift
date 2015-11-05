//
//  ManipulationService.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-03.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class ManipulationService : NSObject
{
    private weak var catagoriesDAO : CatagoriesDAO!
    private weak var recordsDAO : RecordsDAO!
    private weak var receiptsDAO : ReceiptsDAO!
    private weak var taxYearsDAO : TaxYearsDAO!
    
    override init()
    {
        super.init()
    }
    
    init(catagoriesDAO : CatagoriesDAO!, recordsDAO : RecordsDAO!, receiptsDAO : ReceiptsDAO!, taxYearsDAO : TaxYearsDAO!)
    {
        self.catagoriesDAO = catagoriesDAO
        self.recordsDAO = recordsDAO
        self.receiptsDAO = receiptsDAO
        self.taxYearsDAO = taxYearsDAO
    }
    
    func addCatagoryForName(catagoryName : String!, catagoryColor : UIColor!, save: Bool) -> Bool
    {
        return (self.catagoriesDAO.addCatagoryForName(catagoryName, andColor: catagoryColor, save: save))
    }
    
    func modifyCatagoryForCatagoryID(catagoryID : String!, catagoryName : String!, catagoryColor : UIColor!, save : Bool) -> Bool
    {
        return (self.catagoriesDAO.modifyCatagory(catagoryID, forName: catagoryName, andColor: catagoryColor, save:save))
    }
    
    func deleteCatagoryForCatagoryID(catagoryID : String!, save : Bool) -> Bool
    {
        return self.catagoriesDAO.deleteCatagory(catagoryID, save: save)
    }
    
    func transferCatagoryFromCatagoryID(fromCatagoryID : String!, toCatagoryID : String!, save : Bool) -> Bool
    {
        let fromRecords : [Record] = self.recordsDAO.loadRecordsforCatagory(fromCatagoryID) as! [Record]
        
        if (fromRecords.count == 0)
        {
            // nothing to transfer
            return true
        }
        
        let toItemCatagory : ItemCategory? = self.catagoriesDAO.loadCatagory(toCatagoryID)
        
        if (toItemCatagory == nil)
        {
            return false
        }
        
        for record in fromRecords
        {
            if (record == fromRecords.last)
            {
                self.recordsDAO.addRecordForCatagoryID(toItemCatagory!.localID, andReceiptID: record.receiptID, forQuantity: record.quantity, orUnit: record.unitType, forAmount: record.amount, save: true)
            }
            else
            {
                self.recordsDAO.addRecordForCatagoryID(toItemCatagory!.localID, andReceiptID: record.receiptID, forQuantity: record.quantity, orUnit: record.unitType, forAmount: record.amount, save: false)
            }
        }
        
        return true
    }
    
    func addOrUpdateNationalAverageCostForCatagoryID(catagoryID : String!, unitType : Int, amount : Float, save : Bool) -> Bool
    {
        let catagoryToModify : ItemCategory? = self.catagoriesDAO.loadCatagory(catagoryID)
        
        if (catagoryToModify == nil)
        {
            return false
        }
        
        if (self.catagoriesDAO.addOrUpdateNationalAverageCostForCatagoryID(catagoryID, andUnitType:unitType, amount:amount, save: save))
        {
            return true
        }
        
        return false
    }
    
    func deleteNationalAverageCostForCatagoryID(catagoryID : String!, unitType : UnitTypes, save : Bool) -> Bool
    {
        let catagoryToModify : ItemCategory? = self.catagoriesDAO.loadCatagory(catagoryID)
        
        if (catagoryToModify == nil)
        {
            return false
        }
        
        return (self.catagoriesDAO.deleteNationalAverageCostForCatagoryID(catagoryID, andUnitType: unitType.rawValue, save: save))
    }
    
    func addRecordForCatagoryID(catagoryID : String!, receiptID : String!, quantity : Int, unitType : UnitTypes, amount : Float, save : Bool) -> String?
    {
        let toItemCatagory : ItemCategory? = self.catagoriesDAO.loadCatagory(catagoryID)
        
        if (toItemCatagory == nil)
        {
            return nil
        }
        
        let newestRecordID : String? = self.recordsDAO.addRecordForCatagoryID(catagoryID, andReceiptID: receiptID, forQuantity: quantity, orUnit:unitType.rawValue, forAmount: amount, save:save)
        
        if (newestRecordID != nil)
        {
            return newestRecordID
        }
        
        return nil
    }
    
    func deleteRecord(recordID : String!, save : Bool) -> Bool
    {
        let arrayWithSingleNumber : [String] = [recordID]
        
        return self.recordsDAO.deleteRecordsForRecordIDs(arrayWithSingleNumber, save: save)
    }
    
    func modifyRecord(record : Record!, save : Bool) -> Bool
    {
        return self.recordsDAO.modifyRecord(record, save: save)
    }
    
    func addReceiptForFilenames(filenames : [String]!, taxYear : Int, save : Bool) -> String?
    {
        if ( filenames.count == 0 )
        {
            return nil
        }
        
        let newReceiptID : String? = self.receiptsDAO.addReceiptWithFilenames(filenames, inTaxYear: taxYear, save: save)
        
        if ( newReceiptID != nil )
        {
            // send a kReceiptDatabaseChangedNotification notification when a Receipt is added or deleted
            NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: Notifications.kReceiptDatabaseChangedNotification, object: nil))
            
            return newReceiptID
        }
        
        return nil
    }
    
    func modifyReceipt(receipt : Receipt!, save : Bool) -> Bool
    {
        return self.receiptsDAO.modifyReceipt(receipt, save: save)
    }
    
    func deleteReceiptAndAllItsRecords(receiptID : String!, save : Bool) -> Bool
    {
        let recordsForThisReceipt : [Record] = self.recordsDAO.loadRecordsforReceipt(receiptID) as! [Record]
        
        var arrayOfReceiptIDs : [String] = []
        
        for recordToDelete in recordsForThisReceipt
        {
            arrayOfReceiptIDs.append(recordToDelete.localID)
        }
        
        if (self.recordsDAO.deleteRecordsForRecordIDs(arrayOfReceiptIDs, save: save))
        {
            if (self.receiptsDAO.deleteReceipt(receiptID, save: save))
            {
                // send a kReceiptDatabaseChangedNotification notification when a Receipt is added or deleted
                NSNotificationCenter.defaultCenter().postNotification(NSNotification.init(name: Notifications.kReceiptDatabaseChangedNotification, object: nil))
        
                return true
            }
        }
        
        return false
    }
    
    func addTaxYear(taxYear : Int, save : Bool) -> Bool
    {
        return self.taxYearsDAO.addTaxYear(taxYear, save: save)
    }
}