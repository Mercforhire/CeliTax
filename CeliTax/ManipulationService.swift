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
    private weak var categoriesDAO : CategoriesDAO!
    private weak var recordsDAO : RecordsDAO!
    private weak var receiptsDAO : ReceiptsDAO!
    private weak var taxYearsDAO : TaxYearsDAO!
    
    override init()
    {
        super.init()
    }
    
    init(categoriesDAO : CategoriesDAO!, recordsDAO : RecordsDAO!, receiptsDAO : ReceiptsDAO!, taxYearsDAO : TaxYearsDAO!)
    {
        self.categoriesDAO = categoriesDAO
        self.recordsDAO = recordsDAO
        self.receiptsDAO = receiptsDAO
        self.taxYearsDAO = taxYearsDAO
    }
    
    func addCatagoryForName(categoryName : String!, categoryColor : UIColor!, save: Bool) -> Bool
    {
        return (self.categoriesDAO.addCategoryForName(categoryName, color: categoryColor, save: save))
    }
    
    func modifyCatagoryForCatagoryID(categoryID : String!, categoryName : String!, categoryColor : UIColor!, save : Bool) -> Bool
    {
        return (self.categoriesDAO.modifyCategory(categoryID, name: categoryName, color: categoryColor, save:save))
    }
    
    func deleteCatagoryForCatagoryID(categoryID : String!, save : Bool) -> Bool
    {
        return self.categoriesDAO.deleteCategory(categoryID, save: save)
    }
    
    func transferCategoryFromCategoryID(fromCategoryID : String!, toCategoryID : String!, save : Bool) -> Bool
    {
        let fromRecords : [Record] = self.recordsDAO.fetchRecordsforCategory(fromCategoryID)
        
        if (fromRecords.count == 0)
        {
            // nothing to transfer
            return true
        }
        
        let toItemCatagory : ItemCategory? = self.categoriesDAO.fetchCategory(toCategoryID)
        
        if (toItemCatagory == nil)
        {
            return false
        }
        
        for record in fromRecords
        {
            self.recordsDAO.addRecordForCategoryID(toItemCatagory!.localID, receiptID: record.receiptID, quantity: record.quantity, unitType: record.unitType, amount: record.amount, save: false)
        }
        
        deleteCatagoryForCatagoryID(fromCategoryID, save: true)
        
        return true
    }
    
    func addOrUpdateNationalAverageCostForCatagoryID(categoryID : String!, unitType : UnitTypes, amount : Float, save : Bool) -> Bool
    {
        let categoryToModify : ItemCategory? = self.categoriesDAO.fetchCategory(categoryID)
        
        if (categoryToModify == nil)
        {
            return false
        }
        
        if (self.categoriesDAO.addOrUpdateNationalAverageCostForCategoryID(categoryID, unitType:unitType, amount:amount, save: save))
        {
            return true
        }
        
        return false
    }
    
    func deleteNationalAverageCostForCategoryID(categoryID : String!, unitType : UnitTypes, save : Bool) -> Bool
    {
        let catagoryToModify : ItemCategory? = self.categoriesDAO.fetchCategory(categoryID)
        
        if (catagoryToModify == nil)
        {
            return false
        }
        
        return (self.categoriesDAO.deleteNationalAverageCostForCategoryID(categoryID, unitType: unitType, save: save))
    }
    
    func addRecordForCatagoryID(catagoryID : String!, receiptID : String!, quantity : Int, unitType : UnitTypes, amount : Float, save : Bool) -> String?
    {
        let toItemCatagory : ItemCategory? = self.categoriesDAO.fetchCategory(catagoryID)
        
        if (toItemCatagory == nil)
        {
            return nil
        }
        
        let newestRecordID : String? = self.recordsDAO.addRecordForCategoryID(catagoryID, receiptID: receiptID, quantity: quantity, unitType:unitType, amount: amount, save:save)
        
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
        
        let newReceiptID : String? = self.receiptsDAO.addReceiptWithFilenames(filenames, taxYear: taxYear, save: save)
        
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
        let recordsForThisReceipt : [Record] = self.recordsDAO.fetchRecordsforReceipt(receiptID)
        
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