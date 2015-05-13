//
//  DAOFactory.m
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "DAOFactory.h"
#import "CatagoriesDAO.h"

@interface DAOFactory ()

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;

@end

@implementation DAOFactory

- (CatagoriesDAO *) createCatagoriesDAO
{
    if (!self.catagoriesDAO)
    {
        self.catagoriesDAO = [[CatagoriesDAO alloc] init];
    }
    
    return self.catagoriesDAO;
}

@end
