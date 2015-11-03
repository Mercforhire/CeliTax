//
//  AddCategoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "ManipulationService.h"

@class DataService;

@interface AddCategoryViewController : BaseViewController

@property (nonatomic, weak) id <ManipulationService> manipulationService;
@property (nonatomic, weak) DataService *dataService;

@end
