//
//  MainViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-01.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "DataService.h"

typedef void (^RevealBlock)();

@interface MainViewController : BaseViewController

@property (nonatomic, weak) id <DataService> dataService;

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

@end
