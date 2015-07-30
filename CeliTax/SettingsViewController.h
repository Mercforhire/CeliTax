//
//  SettingsViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "SyncService.h"

@class SyncManager;

@interface SettingsViewController : BaseSideBarViewController

@property (nonatomic, weak) id <SyncService> syncService;

@property (nonatomic, weak) SyncManager *syncManager;

@end
