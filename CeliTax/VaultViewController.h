//
//  VaultViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "ManipulationService.h"

@class DataService;

@interface VaultViewController : BaseSideBarViewController

@property (nonatomic, weak) DataService *dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

@end
