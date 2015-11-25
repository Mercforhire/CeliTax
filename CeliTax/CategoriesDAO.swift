//
//  CatagoriesDAO.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-06.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation
import UIKit

@objc
class CategoriesDAO : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
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
    
    /**
    @return Array of ItemCategory,
    */
    func fetchCategories() -> [ItemCategory]!
    {
        let loadCategories : NSPredicate = NSPredicate.init(format: "dataAction != %ld", DataActionStatus.DataActionDelete.rawValue)
        
        let catagories : [ItemCategory] = (self.userDataDAO.getCategories() as NSArray).filteredArrayUsingPredicate(loadCategories) as! [ItemCategory]
        
        return catagories
    }
    
    /**
    @return ItemCategory, nil if user not found or ItemCategory not found
    */
    func fetchCategory(catagoryID : String!) -> ItemCategory?
    {
        let findCategories : NSPredicate = NSPredicate.init(format: "localID == %@ AND dataAction != %ld", catagoryID, DataActionStatus.DataActionDelete.rawValue)
        
        let category : [ItemCategory] = (self.userDataDAO.getCategories() as NSArray).filteredArrayUsingPredicate(findCategories) as! [ItemCategory]
        
        return category.first
    }
    
    /**
    @param name NSString name
    @param color UIColor color
    @param save BOOL save to disk at end of operation
    
    @return YES if success
    */
    func addCategoryForName(name : String!, color : UIColor!, save : Bool) -> Bool
    {
        let categoryToAdd : ItemCategory = ItemCategory()
        
        categoryToAdd.localID = Utils.generateUniqueID()
        categoryToAdd.name = name
        categoryToAdd.color = color
        categoryToAdd.dataAction = DataActionStatus.DataActionInsert
        
        self.userDataDAO.addCategory(categoryToAdd)
        
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
    @param catagoryID NSString ItemCategory to modify ID
    @param name NSString name
    @param color UIColor color
    @param save BOOL save to disk at end of operation
    
    @return YES if success
    */
    func modifyCategory(categoryID : String!, name : String!, color : UIColor!, save : Bool) -> Bool
    {
        let findCategories : NSPredicate = NSPredicate.init(format: "localID == %@", categoryID)
        
        let category : [ItemCategory] = (self.userDataDAO.getCategories() as NSArray).filteredArrayUsingPredicate(findCategories) as! [ItemCategory]
        
        if (category.count > 0)
        {
            let categoryToModify : ItemCategory! = category.first
            
            categoryToModify.name = name
            categoryToModify.color = color
            
            if (categoryToModify.dataAction != DataActionStatus.DataActionInsert)
            {
                categoryToModify.dataAction = DataActionStatus.DataActionUpdate
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
    @param catagoryID NSString ID of ItemCategory to delete
    @param save BOOL save to disk at end of operation
    
    @return YES if success
    */
    func deleteCategory(categoryID : String!, save : Bool) -> Bool
    {
        //delete the existing ItemCategory with same ID as category's ID
        let findCategories : NSPredicate = NSPredicate.init(format: "localID == %@", categoryID)
        let categoriesToDelete : [ItemCategory] = (self.fetchCategories() as NSArray).filteredArrayUsingPredicate(findCategories) as! [ItemCategory]
        
        for categoryToDelete in categoriesToDelete
        {
            categoryToDelete.dataAction = DataActionStatus.DataActionDelete
        }
        
        //delete any records belonging to the Category
        let findRecords : NSPredicate = NSPredicate.init(format: "categoryID == %@", categoryID)
        let recordsToDelete : [Record] = (self.userDataDAO.getRecords() as NSArray).filteredArrayUsingPredicate(findRecords) as! [Record]
        
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
    
    func addCategory(category : ItemCategory!, save : Bool) -> Bool
    {
        if (self.userDataDAO.addCategory(category))
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
        else
        {
            return false
        }
    }
    
    /**
    @param catagories NSArray of ItemCategory objects to merge with
    any ItemCategory with existing ItemCategory in local Database of same id will be updated with new data
    any ItemCategory that doesn't exist locally will be added as new ones
    @param save BOOL save to disk at end of operation
    
    @return YES if success
    */
    func mergeWith(categories : [ItemCategory]!, save : Bool)-> Bool
    {
        let localCategories : NSMutableArray = NSMutableArray.init(array: self.fetchCategories())
        
        for category in categories
        {
            //find any existing ItemCategory with same id as this new one
            let findCategory : NSPredicate = NSPredicate.init(format: "localID == %@", category.localID)
            
            let existingCategory : NSArray = localCategories.filteredArrayUsingPredicate(findCategory)
            
            if (existingCategory.count > 0)
            {
                let existing : ItemCategory = existingCategory.firstObject as! ItemCategory
                
                existing.copyDataFromCategory(category)
                
                existing.dataAction = DataActionStatus.DataActionNone
                
                localCategories.removeObject(existing)
            }
            else
            {
                //add new category if doesn't exist
                self.addCategory(category, save: false)
            }
        }
        
        //for any local ItemCategory that the server doesn't have and isn't marked DataActionInsert,
        //we need to set these to DataActionInsert again so that can be uploaded to the server next time
        for data in localCategories
        {
            if let category = data as? ItemCategory
            {
                category.dataAction = DataActionStatus.DataActionInsert
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
    
    func addOrUpdateNationalAverageCostForCategoryID(categoryID : String!, unitType : UnitTypes, amount : Float, save : Bool) -> Bool
    {
        let findCategories : NSPredicate = NSPredicate.init(format: "localID == %@", categoryID)
        let category : [ItemCategory] = (self.userDataDAO.getCategories() as NSArray).filteredArrayUsingPredicate(findCategories) as! [ItemCategory]
        
        if (category.count > 0)
        {
            let categoryToModify : ItemCategory! = category.first
            
            // Do modifying here
            categoryToModify.addOrUpdateNationalAverageCostForUnitType(unitType, amount:amount)
            
            if (categoryToModify.dataAction != DataActionStatus.DataActionInsert)
            {
                categoryToModify.dataAction = DataActionStatus.DataActionUpdate
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
    
    func deleteNationalAverageCostForCategoryID(categoryID : String!, unitType : UnitTypes, save : Bool) -> Bool
    {
        let findCategories : NSPredicate = NSPredicate.init(format: "localID == %@", categoryID)
        let category : [ItemCategory] = (self.userDataDAO.getCategories() as NSArray).filteredArrayUsingPredicate(findCategories) as! [ItemCategory]
        
        if (category.count > 0)
        {
            let categoryToModify : ItemCategory! = category.first
            
            // Do modifying here
            categoryToModify.deleteNationalAverageCostForUnitType(unitType)
            
            if (categoryToModify.dataAction != DataActionStatus.DataActionInsert)
            {
                categoryToModify.dataAction = DataActionStatus.DataActionUpdate
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
}