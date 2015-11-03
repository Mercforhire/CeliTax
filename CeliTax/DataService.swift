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
    
    weak var catagoriesDAO : CatagoriesDAO!
    weak var recordsDAO : RecordsDAO!
    weak var receiptsDAO : ReceiptsDAO!
    weak var taxYearsDAO : TaxYearsDAO!
    
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
    
    func fetchCatagories() -> [ItemCategory]!
    {
        let catagories : [ItemCategory] = self.catagoriesDAO.loadCatagories() as! [ItemCategory]
        
        return catagories
    }
    
    func fetchCatagory(catagoryID : String) -> ItemCategory?
    {
        let category : ItemCategory? = self.catagoriesDAO.loadCatagory(catagoryID)
        
        if (category != nil)
        {
            return category
        }
        
        return nil
    }
    
    func fetchAllRecords() -> [Record]
    {
        let records : [Record] = self.recordsDAO.loadRecords() as! [Record]
        
        return records;
    }
    
    func fetchRecordsForCatagoryID(catagoryID : String, taxYear : Int) -> [Record]
    {
        let recordsFromAllTime : [Record] = self.recordsDAO.loadRecordsforCatagory(catagoryID) as! [Record]
        
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
    
    func fetchRecordsForReceiptID(receiptID : String) -> [Record]
    {
        let records : [Record] = self.recordsDAO.loadRecordsforReceipt(receiptID) as! [Record]
        
        return records
    }
    
    func fetchRecordForID(recordID : String) -> Record?
    {
        let record : Record = self.recordsDAO.loadRecord(recordID)
        
        return record
    }
    
    func fetchReceiptsInTaxYear(taxYear : Int) -> [Receipt]
    {
        let receipts : [Receipt] = self.receiptsDAO.loadReceiptsFromTaxYear(taxYear) as! [Receipt]
        
        return receipts
    }
    
    func fetchNewestReceiptInfo(nThNewest : Int, year : Int) -> [Dictionary<String, AnyObject>]
    {
        var receiptInfos : [Dictionary<String, AnyObject>] = []
        
        let receipts : [Receipt] = self.receiptsDAO.loadNewestNthReceipts(nThNewest, inTaxYear:year) as! [Receipt]
        
        for receipt in receipts
        {
            var receiptInfo : Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            
            receiptInfo[DataService.kReceiptIDKey] = receipt.localID
            receiptInfo[DataService.kUploadTimeKey] = receipt.dateCreated
            
            var totalAmountForReceipt : Float  = 0.0
            
            // get all catagories for this receipt
            let records : [Record] = self.recordsDAO.loadRecordsforReceipt(receipt.localID) as! [Record]
            
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
    
    func fetchReceiptInfoFromDate(fromDate : NSDate, toDate : NSDate, taxYear : Int) -> [Dictionary<String, AnyObject>]
    {
        var receiptInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceipts : NSArray = self.receiptsDAO.loadReceiptsFromTaxYear(taxYear)
        
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
            let records : [Record] = self.recordsDAO.loadRecordsforReceipt(receipt.localID) as! [Record]
            
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
    
    func fetchReceiptForReceiptID(receiptID : String) -> Receipt?
    {
        let receipt : Receipt = self.receiptsDAO.loadReceipt(receiptID)
        
        return receipt
    }
    
    func fetchCatagoryInfoFromDate(fromDate : NSDate, toDate : NSDate, taxYear : Int, catagoryID : String, unitType : Int) -> [Dictionary<String, AnyObject> ]
    {
        var catagoryInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceiptsFromTheDateRange : [Receipt] = self.receiptsDAO.loadReceiptsFrom(fromDate, toDate: toDate, inTaxYear: taxYear) as! [Receipt]
        
        // filter out the receipts that contains Records of category: catagoryID
        for receipt in allReceiptsFromTheDateRange
        {
            let recordsWithGivenCatagoryID : [Record] = self.recordsDAO.fetchRecordsOfCatagory(catagoryID, inReceipt: receipt.localID) as! [Record]
            
            if (recordsWithGivenCatagoryID.count > 0)
            {
                var totalQty : Int = 0
                var totalAmount : Float = 0.0
                
                // calculate totalQty and totalAmount
                for record in recordsWithGivenCatagoryID
                {
                    if (record.unitType != unitType)
                    {
                        continue
                    }
                    
                    totalQty = totalQty + record.quantity
                    totalAmount = totalAmount + record.calculateTotal()
                }
                
                var catagoryInfo : Dictionary<String, AnyObject> = [:]
                
                catagoryInfo[DataService.kReceiptIDKey] = receipt.localID
                catagoryInfo[DataService.kReceiptTimeKey] = receipt.dateCreated
                catagoryInfo[DataService.kTotalQtyKey] = totalQty
                catagoryInfo[DataService.kTotalAmountKey] = totalAmount
                
                catagoryInfos.append(catagoryInfo)
            }
        }
        
        return catagoryInfos
    }
    
    func fetchLatestNthCatagoryInfosforCatagory(catagoryID : String, unitType : Int, nTh : Int, taxYear : Int) -> [Dictionary<String, AnyObject>]
    {
        var catagoryInfos : [Dictionary<String, AnyObject>] = []
        
        let allReceipts : NSArray = self.receiptsDAO.loadReceiptsFromTaxYear(taxYear)
        
        let sortedAllReceipts : [Receipt] = allReceipts.sortedArrayUsingComparator { (a, b) -> NSComparisonResult in
            
            let first : NSDate! = (a as! Receipt).dateCreated
            let second : NSDate! = (b as! Receipt).dateCreated
            
            return second.compare(first)
            
        } as! [Receipt]
        
        var counter : Int = 0;
        
        // filter out the receipts that contains Records of category: catagoryID
        for receipt in sortedAllReceipts
        {
            if (counter >= nTh && nTh != -1)
            {
                break
            }
            
            let recordsWithGivenCatagoryID : [Record] = self.recordsDAO.fetchRecordsOfCatagory(catagoryID, ofUnitType:unitType, inReceipt:receipt.localID) as! [Record]
            
            if (recordsWithGivenCatagoryID.count > 0)
            {
                var totalQty : Int = 0
                var totalAmount : Float = 0.0
                
                // calculate totalQty and totalAmount
                for record in recordsWithGivenCatagoryID
                {
                    if (record.unitType != unitType)
                    {
                        continue
                    }
                    
                    totalQty = totalQty + record.quantity
                    totalAmount = totalAmount + record.calculateTotal()
                }
                
                var catagoryInfo : Dictionary<String, AnyObject> = [:]
                
                catagoryInfo[DataService.kReceiptIDKey] = receipt.localID
                catagoryInfo[DataService.kReceiptTimeKey] = receipt.dateCreated
                catagoryInfo[DataService.kTotalQtyKey] = totalQty
                catagoryInfo[DataService.kTotalAmountKey] = totalAmount
                
                catagoryInfos.append(catagoryInfo)
                
                counter++
            }
        }
        
        return catagoryInfos
    }
    
    func fetchTaxYears() -> [Int]
    {
        let unsortedTaxYears : [Int] = self.taxYearsDAO.loadAllTaxYears() as! [Int]
        
        let sortedYears : [Int] = unsortedTaxYears.sort { (a, b) -> Bool in
            
            return b < a
            
        }
        
        return sortedYears;
    }
}