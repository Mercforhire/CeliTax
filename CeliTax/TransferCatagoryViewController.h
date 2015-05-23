//
//  TransferCatagoryViewController.h
//  CeliTax
//
//  Created by Leon Chen on 2015-05-02.
//  Copyright (c) 2015 CraveNSave. All rights reserved.
//

#import "BaseViewController.h"
#import "ManipulationService.h"
#import "DataService.h"
#import "PopUpViewControllerProtocol.h"

@class Catagory;

@interface TransferCatagoryViewController : BaseViewController

@property CGSize viewSize;

@property (copy, nonatomic) Catagory *fromCatagory;

@property (nonatomic, weak) id <DataService> dataService;
@property (nonatomic, weak) id <ManipulationService> manipulationService;

@property (nonatomic, weak) id <PopUpViewControllerProtocol> delegate;

@end
