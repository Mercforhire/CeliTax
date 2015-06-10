//
//  VaultViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseSideBarViewController.h"
#import "DataService.h"

@interface VaultViewController : BaseSideBarViewController

@property (nonatomic, weak) id <DataService> dataService;

@end
