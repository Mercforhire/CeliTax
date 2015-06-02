//
//  MyAccountViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "DataService.h"

@interface MyAccountViewController : BaseSideBarViewController

@property (nonatomic, weak) id <DataService> dataService;


@end
