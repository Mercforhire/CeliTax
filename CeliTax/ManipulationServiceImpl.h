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

@property (nonatomic, strong) CatagoriesDAO     *catagoriesDAO;
@property (nonatomic, strong) RecordsDAO        *recordsDAO;
@property (nonatomic, strong) ReceiptsDAO       *receiptsDAO;
@property (nonatomic, strong) TaxYearsDAO       *taxYearsDAO;

@end
