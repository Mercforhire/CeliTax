//
//  MainViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"

@class SyncManager, DataService, ManipulationService;

@interface MainViewController : BaseSideBarViewController

@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) ManipulationService *manipulationService;
@property (nonatomic, weak) SyncManager *syncManager;

@end
