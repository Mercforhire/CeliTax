//
//  DAOFactory.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-04.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CatagoriesDAO;

@interface DAOFactory : NSObject

- (CatagoriesDAO *) createCatagoriesDAO;

@end
