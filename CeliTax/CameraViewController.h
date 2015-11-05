//
//  CameraOverlayViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-18.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class DataService, ManipulationService;

@interface CameraViewController : BaseViewController

@property (nonatomic, strong) NSString *existingReceiptID; //nil if adding a new receipt

@property (nonatomic, weak) DataService *dataService;

@property (nonatomic, weak) ManipulationService *manipulationService;

@end