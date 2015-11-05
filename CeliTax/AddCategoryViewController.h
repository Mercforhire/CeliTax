//
//  AddCategoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"

@class DataService, ManipulationService;

@interface AddCategoryViewController : BaseViewController

@property (nonatomic, weak) ManipulationService *manipulationService;
@property (nonatomic, weak) DataService *dataService;

@end
