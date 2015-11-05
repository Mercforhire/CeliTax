//
//  ServiceFactory.swift
//  CeliTax
//
//  Created by Leon Chen on 2015-11-05.
//  Copyright © 2015 CraveNSave. All rights reserved.
//

import Foundation

@objc
class ServiceFactory : NSObject //TODO: Remove Subclass to NSObject when the entire app has been converted to Swift
{
    private weak var configurationManager : ConfigurationManager!
    
    private weak var daoFactory : DAOFactory!
    
    private weak var networkCommunicator : NetworkCommunicator!
    
    private weak var builderFactory : BuilderFactory!
    
    private var authenticationService : AuthenticationService?
    
    private var dataService : DataService?
    
    private var manipulationService : ManipulationService?
    
    private var syncService : SyncService?
    
    override init()
    {
        super.init()
    }
    
    init(configurationManager : ConfigurationManager!, daoFactory : DAOFactory!, networkCommunicator : NetworkCommunicator!, builderFactory : BuilderFactory!)
    {
        self.configurationManager = configurationManager
        self.daoFactory = daoFactory
        self.networkCommunicator = networkCommunicator
        self.builderFactory = builderFactory
    }
    
    func createAuthenticationService() -> AuthenticationService!
    {
        if (self.authenticationService == nil)
        {
            self.authenticationService = AuthenticationService.init(userDataDAO: self.daoFactory.createUserDataDAO(), networkCommunicator:self.networkCommunicator)
        }
        
        return self.authenticationService
    }
    
    func createDataService() -> DataService!
    {
        if (self.dataService == nil)
        {
            self.dataService = DataService.init(catagoriesDAO: self.daoFactory.createCatagoriesDAO(), recordsDAO: self.daoFactory.createRecordsDAO(), receiptsDAO : self.daoFactory.createReceiptsDAO(), taxYearsDAO : self.daoFactory.createTaxYearsDAO())
        }
        
        return self.dataService
    }
    
    func createManipulationService() -> ManipulationService!
    {
        if (self.manipulationService == nil)
        {
            self.manipulationService = ManipulationService.init(catagoriesDAO: self.daoFactory.createCatagoriesDAO(), recordsDAO:self.daoFactory.createRecordsDAO(), receiptsDAO:self.daoFactory.createReceiptsDAO(), taxYearsDAO:self.daoFactory.createTaxYearsDAO())
        }
        
        return self.manipulationService
    }
    
    func createSyncService() -> SyncService!
    {
        if (self.syncService == nil)
        {
            self.syncService = SyncService.init(userDataDAO: self.daoFactory.createUserDataDAO(), taxYearsDAO:self.daoFactory.createTaxYearsDAO(),recordsDAO:self.daoFactory.createRecordsDAO(), receiptsDAO:self.daoFactory.createReceiptsDAO(), catagoriesDAO:self.daoFactory.createCatagoriesDAO(), networkCommunicator:self.networkCommunicator, catagoryBuilder:self.builderFactory.createCatagoryBuilder(), recordBuilder:self.builderFactory.createRecordBuilder(), receiptBuilder:self.builderFactory.createReceiptBuilder(), taxYearBuilder:self.builderFactory.createTaxYearBuilder())
        }
        
        return self.syncService
    }
}