//
//  ReceiptsDAO.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class ReceiptsDAO : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
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
    
    /*
    @param filenames Array of String filenames for this receipt
    
    @return ID of newest receipt added, nil if failed
    */
    func addReceiptWithFilenames(filenames : [String]!, taxYear : Int, save : Bool) -> String?
    {
        let newReceipt : Receipt = Receipt()
        
        newReceipt.localID = Utils.generateUniqueID()
        newReceipt.fileNames = NSMutableArray.init(array: filenames)
        newReceipt.dateCreated = NSDate()
        newReceipt.taxYear = taxYear
        newReceipt.dataAction = DataActionStatus.DataActionInsert
        
        if (self.userDataDAO.addReceipt(newReceipt))
        {
            if (save)
            {
                if ( self.userDataDAO.saveUserData() )
                {
                    return newReceipt.localID
                }
            }
            else
            {
                return newReceipt.localID
            }
        }
        
        return nil
    }
    
    
    func addReceipt(receiptToAdd : Receipt, save : Bool) -> Bool
    {
        if (self.userDataDAO.addReceipt(receiptToAdd))
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
    
    /*
    @return Array of Receipts
    */
    func fetchAllReceipts() -> [Receipt]!
    {
        let filterReceipts : NSPredicate = NSPredicate.init(format: "dataAction != %ld", DataActionStatus.DataActionDelete.rawValue)
        
        let receipts : [Receipt]! = (self.userDataDAO.getReceipts() as NSArray).filteredArrayUsingPredicate(filterReceipts) as! [Receipt]
        
        return receipts
    }
    
    /*
    @return NSArray of Receipts, nil if user not found or has no receipts
    */
    func fetchReceiptsFromTaxYear(taxYear : Int) -> [Receipt]!
    {
        let filterReceipts : NSPredicate = NSPredicate.init(format: "taxYear == %ld", taxYear)

        let receipts : [Receipt]! = (self.fetchAllReceipts() as NSArray).filteredArrayUsingPredicate(filterReceipts) as! [Receipt]
        
        return receipts
    }
    
    /*
    @return NSArray of newest n-th Receipts, nil if user not found or has no receipts
    */
    func fetchNewestNthReceipts(nTh : Int, taxYear : Int) -> [Receipt]!
    {
        let allReceipts : NSArray = self.fetchReceiptsFromTaxYear(taxYear) as NSArray
        
        let sortedAllReceipts : [Receipt] = (allReceipts.sortedArrayUsingComparator { (a, b) -> NSComparisonResult in
            
            let first : NSDate! = (a as! Receipt).dateCreated
            let second : NSDate! = (b as! Receipt).dateCreated
            return second.compare(first)
            
        }) as! [Receipt]
        
        var newestNThReceipts : [Receipt] = []
        
        for receipt in sortedAllReceipts
        {
            if (newestNThReceipts.count == nTh)
            {
                break
            }
            
            newestNThReceipts.append(receipt)
        }
        
        return newestNThReceipts
    }
    
    /*
    @return NSArray of Receipts from fromDate to toDate
    */
    func fetchReceiptsFrom(fromDate : NSDate, toDate : NSDate, taxYear : Int) -> [Receipt]!
    {
        let allReceipts : NSArray = self.fetchReceiptsFromTaxYear(taxYear)
        
        let filterReceipts : NSPredicate = NSPredicate.init(format: "((dateCreated >= %@) AND (dateCreated <= %@)) || (dateCreated = nil)", fromDate, toDate)
        
        let allReceiptsInChosenTimeFrame : NSArray = allReceipts.filteredArrayUsingPredicate(filterReceipts)
        
        let sortedAllReceipts : [Receipt]! = (allReceiptsInChosenTimeFrame.sortedArrayUsingComparator { (a, b) -> NSComparisonResult in
            
            let first : NSDate! = (a as! Receipt).dateCreated
            let second : NSDate! = (b as! Receipt).dateCreated
            return second.compare(first)
            
        }) as! [Receipt]
        
        return sortedAllReceipts
    }
    
    /*
    @param receiptID NSString receiptID
    
    @return Receipt object, nil if user not found or receipt not found
    */
    func fetchReceipt(receiptID : String) -> Receipt?
    {
        let findReceipt : NSPredicate = NSPredicate.init(format: "localID == %@", receiptID)

        let receipt : [Receipt] = (self.fetchAllReceipts() as NSArray).filteredArrayUsingPredicate(findReceipt) as! [Receipt]
        
        return receipt.first
    }
    
    /**
    @return YES if success, NO if record is not found in existing database
    */
    func modifyReceipt(receipt : Receipt!, save : Bool) -> Bool
    {
        let receiptToModify : Receipt? = self.fetchReceipt(receipt.localID)
        
        if (receiptToModify != nil)
        {
            receiptToModify!.fileNames = NSMutableArray.init(array: receipt.fileNames)
            
            receiptToModify!.taxYear = receipt.taxYear
            
            if (receiptToModify!.dataAction != DataActionStatus.DataActionInsert)
            {
                receiptToModify!.dataAction = DataActionStatus.DataActionUpdate
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
        
        return false
    }
    
    /*
    @param receiptID NSString receiptID
    
    @return YES if success, NO if receipt not found
    */
    func deleteReceipt(receiptID : String!, save : Bool) -> Bool
    {
        let receiptToDelete : Receipt? = self.fetchReceipt(receiptID)
        
        if (receiptToDelete != nil)
        {
            receiptToDelete!.dataAction = DataActionStatus.DataActionDelete;
            
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
    
    func mergeWith(receipts : [Receipt]!, save : Bool) -> Bool
    {
        let localReceipts : NSMutableArray = NSMutableArray.init(array: self.fetchAllReceipts())
        
        for receipt in receipts
        {
            //find any existing Receipt with same id as this new one
            let findReceipt : NSPredicate = NSPredicate.init(format: "localID == %@", receipt.localID)
            
            let existingReceipt : NSArray = localReceipts.filteredArrayUsingPredicate(findReceipt)
            
            if (existingReceipt.count > 0)
            {
                let existing : Receipt! = existingReceipt.firstObject as! Receipt
                
                existing.copyDataFromReceipt(receipt)
                
                localReceipts.removeObject(existing)
            }
            else
            {
                //add new record if doesn't exist
                self.addReceipt(receipt, save: false)
            }
        }
        
        //for any local Receipt that the server doesn't have and isn't marked DataActionInsert,
        //we need to set these to DataActionInsert again so that can be uploaded to the server next time
        for data in localReceipts
        {
            if let receipt = data as? Receipt
            {
                receipt.dataAction = DataActionStatus.DataActionInsert
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