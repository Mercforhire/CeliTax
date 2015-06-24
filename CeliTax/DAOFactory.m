//
//  DAOFactory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DAOFactory.h"
#import "CatagoriesDAO.h"
#import "UserDataDAO.h"
#import "ReceiptsDAO.h"
#import "RecordsDAO.h"
#import "TaxYearsDAO.h"

@interface DAOFactory ()

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;
@property (nonatomic, strong) UserDataDAO *userDataDAO;
@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;
@property (nonatomic, strong) RecordsDAO *recordsDAO;
@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

@end

@implementation DAOFactory

- (CatagoriesDAO *) createCatagoriesDAO
{
    if (!self.catagoriesDAO)
    {
        self.catagoriesDAO = [[CatagoriesDAO alloc] init];
        self.catagoriesDAO.userDataDAO = [self createUserDataDAO];
    }
    
    return self.catagoriesDAO;
}

- (UserDataDAO *) createUserDataDAO
{
    if (!self.userDataDAO)
    {
        self.userDataDAO = [[UserDataDAO alloc] init];
    }
    
    return self.userDataDAO;
}

- (ReceiptsDAO *) createReceiptsDAO
{
    if (!self.receiptsDAO)
    {
        self.receiptsDAO = [[ReceiptsDAO alloc] init];
        self.receiptsDAO.userDataDAO = [self createUserDataDAO];
    }
    
    return self.receiptsDAO;
}

- (RecordsDAO *) createRecordsDAO
{
    if (!self.recordsDAO)
    {
        self.recordsDAO = [[RecordsDAO alloc] init];
        self.recordsDAO.userDataDAO = [self createUserDataDAO];
        self.recordsDAO.catagoriesDAO = [self createCatagoriesDAO];
    }
    
    return self.recordsDAO;
}

- (TaxYearsDAO *) createTaxYearsDAO
{
    if (!self.taxYearsDAO)
    {
        self.taxYearsDAO = [[TaxYearsDAO alloc] init];
        self.taxYearsDAO.userDataDAO = [self createUserDataDAO];
    }
    
    return self.taxYearsDAO;
}

@end
