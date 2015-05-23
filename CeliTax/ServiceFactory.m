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

@interface ServiceFactory ()

@property (nonatomic, strong) id<AuthenticationService> authenticationService;
@property (nonatomic, strong) id<DataService> dataService;
@property (nonatomic, strong) id<ManipulationService> manipulationService;

@end

@implementation ServiceFactory

- (id<AuthenticationService>) createAuthenticationService
{
    if (!self.authenticationService)
    {
        self.authenticationService = [[AuthenticationServiceImpl alloc] init];
        self.authenticationService.userDataDAO = [self.daoFactory createUserDataDAO];
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
    }
    
    return self.manipulationService;
}

@end