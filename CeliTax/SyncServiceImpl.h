//
//  SyncServiceImpl.h
//  CeliTax
//
//  Created by Leon Chen on 2015-07-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncService.h"

@interface SyncServiceImpl : NSObject <SyncService>

@property (nonatomic, strong) UserDataDAO *userDataDAO;

@property (nonatomic, strong) TaxYearsDAO *taxYearsDAO;

@property (nonatomic, strong) RecordsDAO *recordsDAO;

@property (nonatomic, strong) ReceiptsDAO *receiptsDAO;

@property (nonatomic, strong) CatagoriesDAO *catagoriesDAO;

@property (nonatomic, strong) NetworkCommunicator *networkCommunicator;

@property (nonatomic, strong) CatagoryBuilder *catagoryBuilder;

@property (nonatomic, strong) RecordBuilder *recordBuilder;

@property (nonatomic, strong) ReceiptBuilder *receiptBuilder;

@property (nonatomic, strong) TaxYearBuilder *taxYearBuilder;

@end
