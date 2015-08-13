//
//  ServiceFactory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ServiceFactory.h"
#import "AuthenticationService.h"
#import "AuthenticationServiceImpl.h"
#import "DataService.h"
#import "DataServiceImpl.h"
#import "DAOFactory.h"
#import "ManipulationService.h"
#import "ManipulationServiceImpl.h"
#import "SyncService.h"
#import "SyncServiceImpl.h"
#import "BuilderFactory.h"

@interface ServiceFactory ()

@property (nonatomic, strong) id<AuthenticationService> authenticationService;
@property (nonatomic, strong) id<DataService> dataService;
@property (nonatomic, strong) id<ManipulationService> manipulationService;
@property (nonatomic, strong) id<SyncService> syncService;

@end

@implementation ServiceFactory

- (id<AuthenticationService>) createAuthenticationService
{
    if (!self.authenticationService)
    {
        self.authenticationService = [[AuthenticationServiceImpl alloc] init];
        self.authenticationService.userDataDAO = [self.daoFactory createUserDataDAO];
        self.authenticationService.networkCommunicator = self.networkCommunicator;
    }
    
    return self.authenticationService;
}

- (id<DataService>) createDataService
{
    if (!self.dataService)
    {
        self.dataService = [[DataServiceImpl alloc] init];
        self.dataService.catagoriesDAO = [self.daoFactory createCatagoriesDAO];
        self.dataService.recordsDAO = [self.daoFactory createRecordsDAO];
        self.dataService.receiptsDAO = [self.daoFactory createReceiptsDAO];
        self.dataService.taxYearsDAO = [self.daoFactory createTaxYearsDAO];
    }
    
    return self.dataService;
}

- (id<ManipulationService>) createManipulationService
{
    if (!self.manipulationService)
    {
        self.manipulationService = [[ManipulationServiceImpl alloc] init];
        self.manipulationService.catagoriesDAO = [self.daoFactory createCatagoriesDAO];
        self.manipulationService.recordsDAO = [self.daoFactory createRecordsDAO];
        self.manipulationService.receiptsDAO = [self.daoFactory createReceiptsDAO];
        self.manipulationService.taxYearsDAO = [self.daoFactory createTaxYearsDAO];
    }
    
    return self.manipulationService;
}

- (id<SyncService>) createSyncService
{
    if (!self.syncService)
    {
        self.syncService = [[SyncServiceImpl alloc] init];
        self.syncService.userDataDAO = [self.daoFactory createUserDataDAO];
        self.syncService.networkCommunicator = self.networkCommunicator;
        self.syncService.catagoriesDAO = [self.daoFactory createCatagoriesDAO];
        self.syncService.recordsDAO = [self.daoFactory createRecordsDAO];
        self.syncService.receiptsDAO = [self.daoFactory createReceiptsDAO];
        self.syncService.taxYearsDAO = [self.daoFactory createTaxYearsDAO];
        self.syncService.catagoryBuilder = [self.builderFactory createCatagoryBuilder];
        self.syncService.recordBuilder = [self.builderFactory createRecordBuilder];
        self.syncService.receiptBuilder = [self.builderFactory createReceiptBuilder];
        self.syncService.taxYearBuilder = [self.builderFactory createTaxYearBuilder];
    }
    
    return self.syncService;
}

@end
