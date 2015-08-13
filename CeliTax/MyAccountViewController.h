//
//  MyAccountViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "DataService.h"
#import "ManipulationService.h"

@interface MyAccountViewController : BaseSideBarViewController

@property (nonatomic, weak) id <DataService> dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

@end
