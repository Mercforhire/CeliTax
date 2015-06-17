//
//  ReceiptCheckingViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-06.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "DataService.h"
#import "ManipulationService.h"

@interface ReceiptCheckingViewController : BaseViewController

@property (nonatomic, weak) id <DataService> dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property NSString *receiptID;

//True if the previous viewController is ReceiptBreakDownViewController
//False if the previous viewController is MainViewController, right after taking a Photo
@property BOOL cameFromReceiptBreakDownViewController;

@end
