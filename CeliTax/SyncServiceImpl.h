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

@property (nonatomic, weak) UserDataDAO *userDataDAO;

@property (nonatomic, weak) TaxYearsDAO *taxYearsDAO;

@property (nonatomic, weak) RecordsDAO *recordsDAO;

@property (nonatomic, weak) ReceiptsDAO *receiptsDAO;

@property (nonatomic, weak) CatagoriesDAO *catagoriesDAO;

@property (nonatomic, weak) NetworkCommunicator *networkCommunicator;

@property (nonatomic, weak) CategoryBuilder *catagoryBuilder;

@property (nonatomic, weak) RecordBuilder *recordBuilder;

@property (nonatomic, weak) ReceiptBuilder *receiptBuilder;

@property (nonatomic, weak) TaxYearBuilder *taxYearBuilder;

@end
