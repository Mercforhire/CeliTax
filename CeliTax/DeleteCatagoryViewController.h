//
//  DeleteCatagoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "ManipulationService.h"
#import "BaseViewController.h"
#import "ItemCatagory.h"

@interface DeleteCatagoryViewController : BaseViewController

@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property (nonatomic, strong) ItemCatagory *catagoryToDelete;

@end
