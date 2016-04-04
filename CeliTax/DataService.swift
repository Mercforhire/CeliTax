//
//  DataService.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-03.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class DataService : NSObject
{
    static let kReceiptIDKey : String = "ReceiptID"
    static let kUploadTimeKey : String = "UploadTime"
    static let kTotalAmountKey : String = "TotalAmount"
    static let kReceiptTimeKey : String = "ReceiptTime"
    static let kTotalQtyKey : String = "TotalQty"
    static let kNumberOfRecordsKey : String = "NumberOfRecords"
    
    weak var categoriesDAO : CategoriesDAO!
    weak var recordsDAO : RecordsDAO!
    weak var receiptsDAO : ReceiptsDAO!
    weak var taxYearsDAO : TaxYearsDAO!
    
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
    
    // return true, if this userData have absolutely no data
    func isFresh() -> Bool
    {
        if (fetchCategories().count == 0 && fetchAllRecords().count == 0 && self.receiptsDAO.fetchAllReceipts().count == 0)
        {
            return true
        }
        
        return false
    }
    
    func fetchCategories() -> [ItemCategory]!
    {
        let categories : [ItemCategory] = self.categoriesDAO.fetchCategories() 
        
        return categories
    }
    
    func fetchCategory(categoryID : String!) -> ItemCategory?
    {
        let category : ItemCategory? = self.categoriesDAO.fetchCategory(categoryID)
        
        if (category != nil)
        {
            return category
        }
        
        return nil
    }
    
    func fetchAllRecords() -> [Record]
    {
        let records : [Record] = self.recordsDAO.fetchRecords()
        
        return records;
    }
    
    func fetchRecordsForCatagoryID(categoryID : String!, taxYear : Int) -> [Record]
    {
        let recordsFromAllTime : [Record] = self.recordsDAO.fetchRecordsforCategory(categoryID)
        
        var recordsInTaxYear : [Record] = []
        
        for record in recordsFromAllTime
        {
            let receipt : Receipt? = self.fetchReceiptForReceiptID(record.receiptID)
            
            if (receipt != nil)
            {
                if (receipt!.taxYear == taxYear)
                {
                    recordsInTaxYear.append(record)
                }
            }
        }
        
        return recordsInTaxYear
    }
    
    func fetchRecordsForReceiptID(receiptID : String!) -> [Record]
    {
        let records : [Record] = self.recordsDAO.fetchRecordsforReceipt(receiptID)
        
        return records
    }
    
    func fetchRecordForID(recordID : String!) -> Record?
    {
        let record : Record? = self.recordsDAO.fetchRecord(recordID)
        
        return record
    }
    
    func fetchReceiptsInTaxYear(taxYear : Int) -> [Receipt]
    {
        let receipts : [Receipt] = self.receiptsDAO.fetchReceiptsFromTaxYear(taxYear)
        
        return receipts
    }
    
    func fetchNewestReceiptInfo(nThNewest : Int, year : Int) -> [Dictionary<String, AnyObject>]
    {
        var receiptInfos : [Dictionary<String, AnyObject>] = []
        
        let receipts : [Receipt] = self.receiptsDAO.fetchNewestNthReceipts(nThNewest, taxYear:year)
        
        for receipt in receipts
        {
            var receiptInfo : Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            
            receiptInfo[DataService.kReceiptIDKey] = receipt.localID
            receiptInfo[DataService.kUploadTimeKey] = receipt.dateCreated
            
            var totalAmountForReceipt : Float  = 0.0
            
            // get all catagories for this receipt
            let records : [Record] = self.recordsDAO.fetchRecordsforReceipt(receipt.localID)
            
            receiptInfo[DataService.kNumberOfRecordsKey] = records.count
            
            for record in records
            {
                totalAmountForReceipt = totalAmountForReceipt + record.calculateTotal()
            }
            
            receiptInfo[DataService.kTotalAmountKey] = totalAmountForReceipt
            
            receiptInfos.append(receiptInfo)
        }
        
        return receiptInfos
    }
    
    func fetchReceiptInfoFromDate(fromDate : NSDate!, toDate : NSDate!, taxYear : Int) -> [Dictionary<String, AnyObject>]
    {
        var receiptInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceipts : NSArray = self.receiptsDAO.fetchReceiptsFromTaxYear(taxYear)
        
        let predicate : NSPredicate = NSPredicate.init(format: "((dateCreated >= %@) AND (dateCreated < %@)) || (dateCreated = nil)", fromDate, toDate)
        
        let receiptsInGivenTimeFrame : NSArray = allReceipts.filteredArrayUsingPredicate(predicate)
        
        let sortedReceipts : [Receipt] = receiptsInGivenTimeFrame.sortedArrayUsingComparator { (a, b) -> NSComparisonResult in
            
            let first : NSDate! = (a as! Receipt).dateCreated
            let second : NSDate! = (b as! Receipt).dateCreated
            
            return second.compare(first)
            
        } as! [Receipt]
        
        for receipt in sortedReceipts
        {
            var receiptInfo : Dictionary<String, AnyObject> = [:]
            
            receiptInfo[DataService.kReceiptIDKey] = receipt.localID
            receiptInfo[DataService.kUploadTimeKey] = receipt.dateCreated
            
            var totalAmountForReceipt : Float = 0.0
            
            // get all catagories for this receipt
            let records : [Record] = self.recordsDAO.fetchRecordsforReceipt(receipt.localID)
            
            receiptInfo[DataService.kNumberOfRecordsKey] = records.count
            
            for record in records
            {
                totalAmountForReceipt = totalAmountForReceipt + record.calculateTotal()
            }
            
            receiptInfo[DataService.kTotalAmountKey] = totalAmountForReceipt
            
            receiptInfos.append(receiptInfo)
        }
        
        return receiptInfos
    }
    
    func fetchReceiptForReceiptID(receiptID : String!) -> Receipt?
    {
        let receipt : Receipt? = self.receiptsDAO.fetchReceipt(receiptID)
        
        return receipt
    }
    
    func fetchCategoryInfoFromDate(fromDate : NSDate!, toDate : NSDate!, taxYear : Int, categoryID : String!, unitType : UnitTypes) -> [Dictionary<String, AnyObject> ]
    {
        var categoryInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceiptsFromTheDateRange : [Receipt] = self.receiptsDAO.fetchReceiptsFrom(fromDate, toDate: toDate, taxYear: taxYear)
        
        // filter out the receipts that contains Records of category: catagoryID
        for receipt in allReceiptsFromTheDateRange
        {
            let recordsWithGivenCategoryID : [Record] = self.recordsDAO.fetchRecordsOfCategory(categoryID, receiptID: receipt.localID) as [Record]
            
            if (recordsWithGivenCategoryID.count > 0)
            {
                var totalQty : Int = 0
                var totalAmount : Float = 0.0
                
                // calculate totalQty and totalAmount
                for record in recordsWithGivenCategoryID
                {
                    if (record.unitType != unitType)
                    {
                        continue
                    }
                    
                    totalQty = totalQty + record.quantity
                    totalAmount = totalAmount + record.calculateTotal()
                }
                
                var categoryInfo : Dictionary<String, AnyObject> = [:]
                
                categoryInfo[DataService.kReceiptIDKey] = receipt.localID
                categoryInfo[DataService.kReceiptTimeKey] = receipt.dateCreated
                categoryInfo[DataService.kTotalQtyKey] = totalQty
                categoryInfo[DataService.kTotalAmountKey] = totalAmount
                
                categoryInfos.append(categoryInfo)
            }
        }
        
        return categoryInfos
    }
    
    func fetchLatestNthCategoryInfosforCategory(categoryID : String!, unitType : UnitTypes, nTh : Int, taxYear : Int) -> [Dictionary<String, AnyObject>]
    {
        var categoryInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceipts : NSArray = self.receiptsDAO.fetchReceiptsFromTaxYear(taxYear)
        
        let sortedAllReceipts : [Receipt] = (allReceipts.sortedArrayUsingComparator { (a, b) -> NSComparisonResult in
            
            let first : NSDate! = (a as! Receipt).dateCreated
            let second : NSDate! = (b as! Receipt).dateCreated
            
            return second.compare(first)
            
        }) as! [Receipt]
        
        var counter : Int = 0;
        
        // filter out the receipts that contains Records of category: catagoryID
        for receipt in sortedAllReceipts
        {
            if (counter >= nTh && nTh != -1)
            {
                break
            }
            
            let recordsWithGivenCategoryID : [Record] = self.recordsDAO.fetchRecordsOfCategory(categoryID, unitType:unitType, receiptID:receipt.localID)
            
            if (recordsWithGivenCategoryID.count > 0)
            {
                var totalQty : Int = 0
                var totalAmount : Float = 0.0
                
                // calculate totalQty and totalAmount
                for record in recordsWithGivenCategoryID
                {
                    if (record.unitType != unitType)
                    {
                        continue
                    }
                    
                    totalQty = totalQty + record.quantity
                    totalAmount = totalAmount + record.calculateTotal()
                }
                
                var categoryInfo : Dictionary<String, AnyObject> = [:]
                
                categoryInfo[DataService.kReceiptIDKey] = receipt.localID
                categoryInfo[DataService.kReceiptTimeKey] = receipt.dateCreated
                categoryInfo[DataService.kTotalQtyKey] = totalQty
                categoryInfo[DataService.kTotalAmountKey] = totalAmount
                
                categoryInfos.append(categoryInfo)
                
                counter += 1
            }
        }
        
        return categoryInfos
    }
    
    func fetchTaxYears() -> [Int]
    {
        let unsortedTaxYears : [Int] = self.taxYearsDAO.loadAllTaxYears()
        
        let sortedYears : [Int] = unsortedTaxYears.sort { (a, b) -> Bool in
            
            return b < a
            
        }
        
        return sortedYears
    }
}