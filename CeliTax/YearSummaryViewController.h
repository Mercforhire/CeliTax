//
//  TaxYearSummaryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-08-13.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@class DataService, SyncService;

@interface YearSummaryViewController : BaseViewController

@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) SyncService *syncService;

@end
