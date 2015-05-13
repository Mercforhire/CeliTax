//
//  EditCatagoriesViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "DataService.h"

@interface CatagoriesManagementViewController : BaseViewController

@property (nonatomic, weak) id <DataService> dataService;

@end
