//
//  DAOFactory.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class DAOFactory : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private var categoriesDAO : CategoriesDAO?
    private var userDataDAO : UserDataDAO?
    private var receiptsDAO : ReceiptsDAO?
    private var recordsDAO : RecordsDAO?
    private var taxYearsDAO : TaxYearsDAO?
    
    func createCategoriesDAO() -> CategoriesDAO!
    {
        if (self.categoriesDAO == nil)
        {
            self.categoriesDAO = CategoriesDAO.init(userDataDAO: self.createUserDataDAO())
        }
        
        return self.categoriesDAO
    }
    
    func createUserDataDAO() -> UserDataDAO!
    {
        if (self.userDataDAO == nil)
        {
            self.userDataDAO = UserDataDAO()
        }
        
        return self.userDataDAO
    }
    
    func createReceiptsDAO() -> ReceiptsDAO!
    {
        if (self.receiptsDAO == nil)
        {
            self.receiptsDAO = ReceiptsDAO.init(userDataDAO: self.createUserDataDAO())
        }
        
        return self.receiptsDAO
    }
    
    func createRecordsDAO() -> RecordsDAO!
    {
        if (self.recordsDAO == nil)
        {
            self.recordsDAO = RecordsDAO.init(userDataDAO: self.createUserDataDAO(), categoriesDAO: self.createCategoriesDAO())
        }
        
        return self.recordsDAO
    }
    
    func createTaxYearsDAO() -> TaxYearsDAO!
    {
        if (self.taxYearsDAO == nil)
        {
            self.taxYearsDAO = TaxYearsDAO.init(userDataDAO: self.createUserDataDAO())
        }
        
        return self.taxYearsDAO
    }
}