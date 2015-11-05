//
//  ReceiptCheckingViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@class SyncManager, DataService, ManipulationService;

@interface ReceiptCheckingViewController : BaseViewController

@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) ManipulationService *manipulationService;
@property (nonatomic, weak) SyncManager *syncManager;

@property NSString *receiptID;

//True if the previous viewController is ReceiptBreakDownViewController
//False if the previous viewController is MainViewController, right after taking a Photo
@property BOOL cameFromReceiptBreakDownViewController;

@end
