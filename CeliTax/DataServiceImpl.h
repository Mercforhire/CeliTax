//
//  DataServiceImpl.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataService.h"

@class CatagoriesDAO;

@interface DataServiceImpl : NSObject <DataService>

@property (nonatomic, weak) CatagoriesDAO     *catagoriesDAO;
@property (nonatomic, weak) RecordsDAO        *recordsDAO;
@property (nonatomic, weak) ReceiptsDAO       *receiptsDAO;
@property (nonatomic, weak) TaxYearsDAO       *taxYearsDAO;

@end
