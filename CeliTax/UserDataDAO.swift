//
//  UserDataDAO.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class UserDataDAO : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    var userKey : String? {
        didSet
        {
            self.loadUserData()
        }
    }

    private var userData : UserData?
    
    func getCategories() -> [ItemCategory]!
    {
        return self.userData!.categories as NSArray as! [ItemCategory]
    }
    
    func addCategory(category : ItemCategory!) -> Bool
    {
        if (self.userData != nil)
        {
            self.userData!.categories.addObject(category)
            
            return true
        }
        
        return false
    }
    
    func getRecords() -> [Record]!
    {
        return self.userData!.records as NSArray as! [Record]
    }
    
    func addRecord(record : Record!) -> Bool
    {
        if (self.userData != nil)
        {
            self.userData!.records.addObject(record)
            
            return true
        }
        
        return false
    }
    
    func addRecords(records : [Record]!) -> Bool
    {
        if (self.userData != nil)
        {
            self.userData!.records.addObjectsFromArray(records)
            
            return true
        }
        
        return false
    }
    
    func getReceipts() -> [Receipt]!
    {
        return self.userData!.receipts as NSArray as! [Receipt]
    }
    
    func addReceipt(receipt : Receipt!) -> Bool
    {
        if (self.userData != nil)
        {
            self.userData!.receipts.addObject(receipt)
            
            return true
        }
        
        return false
    }
    
    func getTaxYears() -> [TaxYear]!
    {
        return self.userData!.taxYears as NSArray as! [TaxYear]
    }
    
    func addTaxYear(taxYear : TaxYear) -> Bool
    {
        if (self.userData != nil)
        {
            self.userData!.taxYears.addObject(taxYear)
            
            return true
        }
        
        return false
    }
    
    func getLastBackUpDate() -> NSDate?
    {
        return self.userData!.lastUploadedDate
    }
    
    func setLastBackUpDate(date : NSDate!)
    {
        self.userData!.lastUploadedDate = date
    }
    
    func getLastestDataHash() -> String?
    {
        return self.userData!.lastUploadHash
    }
    
    func setLastestDataHash(hash : String!)
    {
        self.userData!.lastUploadHash = hash
    }
    
    func generateUserDataFileName() -> String?
    {
        if (self.userKey == nil)
        {
            return nil
        }
        
        let storagePath : NSString? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        
        if (storagePath != nil)
        {
            let filePath : String = storagePath!.stringByAppendingString( String(format: "/USER_DATA-%@.dat", self.userKey!) )
            
            return filePath
        }
        
        return nil
    }
    
    func loadUserData() -> Bool
    {
        if (self.userKey == nil)
        {
            return false
        }
        
        self.userData = Utils.unarchiveFile(self.generateUserDataFileName()) as? UserData
        
        if (self.userData != nil)
        {
            return true
        }
        else
        {
            self.userData = UserData()
            
            return self.saveUserData()
        }
    }
    
    func saveUserData() -> Bool
    {
        if (self.userKey == nil || self.userData == nil)
        {
            return false
        }
        
        if (Utils.archiveFile(self.userData, toFile: self.generateUserDataFileName()))
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func deleteUserData() -> Bool
    {
        if (self.userKey == nil)
        {
            return false
        }
        
        let fileManager : NSFileManager! = NSFileManager.defaultManager()
        
        let userDataPath : String! = self.generateUserDataFileName()
        
        if ( fileManager.fileExistsAtPath(userDataPath) )
        {
            do
            {
                try fileManager.removeItemAtPath(userDataPath)
                
                return true
            }
            catch
            {
                return false
            }
            
        }
        
        return false
    }
    
    func generateJSONToUploadToServer() -> NSDictionary!
    {
        return self.userData!.generateJSONToUploadToServer()
    }
    
    func resetAllDataActionsAndClearOutDeletedOnes()
    {
        self.userData!.resetAllDataActionsAndClearOutDeletedOnes()
    }
    
}