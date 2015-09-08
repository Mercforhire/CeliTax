//
//  ManipulationServiceImpl.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-05.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManipulationService.h"

@class CatagoriesDAO,RecordsDAO,ReceiptsDAO;

@interface ManipulationServiceImpl : NSObject <ManipulationService>

@property (nonatomic, weak) CatagoriesDAO     *catagoriesDAO;
@property (nonatomic, weak) RecordsDAO        *recordsDAO;
@property (nonatomic, weak) ReceiptsDAO       *receiptsDAO;
@property (nonatomic, weak) TaxYearsDAO       *taxYearsDAO;

@end
